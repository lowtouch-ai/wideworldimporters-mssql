"""
Mechanical T-SQL → PostgreSQL conversion for PostDeploymentScripts.
Handles: GO removal, N'' prefix, bracket-quoted names, datetime variable inlining,
hex POINT geography, PRINT, schema/table name lowercasing via lookup dict.
"""
import re
import sys
import os

# MSSQL CamelCase table name → PostgreSQL snake_case table name
# Key: lowercase version of "schema.table" (for case-insensitive lookup)
TABLE_MAP = {
    'application.cities':                    'application.cities',
    'application.cities_archive':            'application.cities_archive',
    'application.countries':                 'application.countries',
    'application.countries_archive':         'application.countries_archive',
    'application.deliverymethods':           'application.delivery_methods',
    'application.deliverymethods_archive':   'application.delivery_methods_archive',
    'application.logs':                      'application.logs',
    'application.paymentmethods':            'application.payment_methods',
    'application.paymentmethods_archive':    'application.payment_methods_archive',
    'application.people':                    'application.people',
    'application.people_archive':            'application.people_archive',
    'application.stateprovinces':            'application.state_provinces',
    'application.stateprovinces_archive':    'application.state_provinces_archive',
    'application.systemparameters':          'application.system_parameters',
    'application.transactiontypes':          'application.transaction_types',
    'application.transactiontypes_archive':  'application.transaction_types_archive',
    'dataloadsimulation.areacode':           'dataloadsimulation.areacode',
    'dataloadsimulation.coldroomtemperatures_temp': 'dataloadsimulation.coldroomtemperatures_temp',
    'dataloadsimulation.ficticiousnamepool': 'dataloadsimulation.ficticiousnamepool',
    'dataloadsimulation.seasonvariation':    'dataloadsimulation.seasonvariation',
    'dbo.sampleversion':                     'dbo.sampleversion',
    'purchasing.purchaseorderlines':         'purchasing.purchaseorderlines',
    'purchasing.purchaseorders':             'purchasing.purchaseorders',
    'purchasing.suppliercategories':         'purchasing.supplier_categories',
    'purchasing.suppliercategories_archive': 'purchasing.supplier_categories_archive',
    'purchasing.suppliers':                  'purchasing.suppliers',
    'purchasing.suppliers_archive':          'purchasing.suppliers_archive',
    'purchasing.suppliertransactions':       'purchasing.suppliertransactions',
    'sales.buyinggroups':                    'sales.buying_groups',
    'sales.buyinggroups_archive':            'sales.buying_groups_archive',
    'sales.customercategories':              'sales.customer_categories',
    'sales.customercategories_archive':      'sales.customer_categories_archive',
    'sales.customers':                       'sales.customers',
    'sales.customers_archive':              'sales.customers_archive',
    'sales.customertransactions':            'sales.customertransactions',
    'sales.invoicelines':                    'sales.invoicelines',
    'sales.invoices':                        'sales.invoices',
    'sales.orderlines':                      'sales.orderlines',
    'sales.orders':                          'sales.orders',
    'sales.specialdeals':                    'sales.specialdeals',
    'warehouse.coldroomtemperatures':        'warehouse.coldroomtemperatures',
    'warehouse.coldroomtemperatures_archive': 'warehouse.coldroomtemperatures_archive',
    'warehouse.colors':                      'warehouse.colors',
    'warehouse.colors_archive':              'warehouse.colors_archive',
    'warehouse.packagetypes':                'warehouse.package_types',
    'warehouse.packagetypes_archive':        'warehouse.package_types_archive',
    'warehouse.stockgroups':                 'warehouse.stock_groups',
    'warehouse.stockgroups_archive':         'warehouse.stock_groups_archive',
    'warehouse.stockitemholdings':           'warehouse.stockitemholdings',
    'warehouse.stockitems':                  'warehouse.stockitems',
    'warehouse.stockitems_archive':          'warehouse.stockitems_archive',
    'warehouse.stockitemstockgroups':        'warehouse.stockitemstockgroups',
    'warehouse.stockitemtransactions':       'warehouse.stockitemtransactions',
    'warehouse.vehicletemperatures':         'warehouse.vehicletemperatures',
}

def resolve_table(schema: str, table: str) -> str:
    key = f"{schema.lower()}.{table.lower()}"
    return TABLE_MAP.get(key, f"{schema.lower()}.{table.lower()}")

def mssql_date_to_pg(val: str) -> str:
    val = val.strip()
    if len(val) == 8 and val.isdigit():
        return f"{val[:4]}-{val[4:6]}-{val[6:8]} 00:00:00"
    if ' ' in val:
        date_p, rest = val.split(' ', 1)
        if len(date_p) == 8 and date_p.isdigit():
            date_p = f"{date_p[:4]}-{date_p[4:6]}-{date_p[6:8]}"
        if '.' in rest:
            time_p, frac = rest.split('.', 1)
            return f"{date_p} {time_p}.{frac[:6]}"
        return f"{date_p} {rest}"
    return val

def convert_hex_literal(m: re.Match) -> str:
    """
    Convert MSSQL 0x... hex literals:
    - Geography POINT (44 hex chars, SRID prefix e6100000010c) → PostGIS WKB expression
    - Geography polygon/other (longer, SRID prefix e6100000)   → NULL with TODO comment
    - All other hex literals (BYTEA: passwords, etc.)          → decode('...', 'hex')
    """
    hex_val = m.group(1)
    prefix8 = hex_val[:8].upper()

    # MSSQL SRID 4326 prefix: e6100000
    if prefix8 == 'E6100000':
        if len(hex_val) == 44 and hex_val[:12].upper() == 'E6100000010C':
            # Single POINT geography: lat[8B] + lon[8B] after 6-byte header
            lat_hex = hex_val[12:28]
            lon_hex = hex_val[28:44]
            wkb = '0101000000' + lon_hex + lat_hex
            return f"ST_GeomFromWKB(decode('{wkb}', 'hex'), 4326)::geography"
        # Polygon or other complex geography — cannot auto-convert
        short = hex_val[:20]
        return f"NULL /* TODO: convert MSSQL geography binary 0x{short}... to PostGIS */"

    # Regular BYTEA (password hashes, other binary data)
    return f"decode('{hex_val}', 'hex')"

def extract_and_inline_simple_vars(content: str) -> str:
    """Inline DECLARE @Var datetime2(7) = 'literal' constants."""
    var_pattern = re.compile(
        r"^\s*DECLARE\s+@(\w+)\s+(?:AS\s+)?DATETIME2\s*\(\s*7\s*\)\s*=\s*'([^']+)'\s*;?\s*$",
        re.IGNORECASE | re.MULTILINE
    )
    var_values = {}

    def extract_var(m):
        name = m.group(1)
        pg_val = mssql_date_to_pg(m.group(2))
        var_values[name.lower()] = pg_val
        return ''

    content = var_pattern.sub(extract_var, content)

    for name, val in var_values.items():
        content = re.sub(
            rf'@{re.escape(name)}\b',
            f"'{val}'::TIMESTAMP(6)",
            content,
            flags=re.IGNORECASE
        )
    return content

def fix_schema_table(m: re.Match) -> str:
    schema = m.group(1)
    table  = m.group(2)
    return resolve_table(schema, table)

def fix_insert(m: re.Match) -> str:
    schema = m.group(1)
    table  = m.group(2)
    return f'INSERT INTO {resolve_table(schema, table)}'

def convert(content: str) -> str:
    # Strip UTF-8 BOM if present
    content = content.lstrip('﻿')

    # 1. Replace GO batch separators with semicolons (terminates the preceding statement)
    content = re.sub(r'^\s*GO\s*$', ';', content, flags=re.MULTILINE)

    # 2. PRINT 'msg' / PRINT N'msg' → \echo 'msg'
    content = re.sub(
        r"^(\s*)PRINT\s+N?'([^']*)'\s*$",
        r"\1\\echo '\2'",
        content,
        flags=re.MULTILINE
    )

    # 3. Remove N'' Unicode prefix
    content = re.sub(r"\bN'", "'", content)

    # 4. SET NOCOUNT ON → remove
    content = re.sub(r'^\s*SET\s+NOCOUNT\s+ON\s*;?\s*$', '', content, flags=re.MULTILINE | re.IGNORECASE)

    # 5. Inline simple datetime2 DECLARE variables
    content = extract_and_inline_simple_vars(content)

    # 6. Convert hex literals: geography POINT → PostGIS WKB; polygon → NULL; other → decode(...)
    content = re.sub(r'0x([0-9a-fA-F]+)', convert_hex_literal, content, flags=re.IGNORECASE)

    # 7. [Schema].[Table] → resolved pg name
    content = re.sub(r'\[(\w+)\]\.\[(\w+)\]', fix_schema_table, content)
    # [Schema].Table (second part unbracketed)
    content = re.sub(r'\[(\w+)\]\.(\w+)', fix_schema_table, content)

    # 7b. Unbracketed Schema.Table where Schema is a known WWI schema
    _KNOWN_SCHEMAS = r'(?:Application|DataLoadSimulation|Purchasing|Sales|Warehouse|Website|Integration|Security|WebApi|Sequences|Dbo)'
    content = re.sub(
        rf'\b({_KNOWN_SCHEMAS})\.(\w+)\b',
        fix_schema_table,
        content,
        flags=re.IGNORECASE
    )

    # 8. INSERT Schema.Table (no INTO) → INSERT INTO resolved_pg_name
    content = re.sub(
        r'\bINSERT\s+(?!INTO\b)(\w+)\.(\w+)\b',
        fix_insert,
        content,
        flags=re.IGNORECASE
    )

    # 7c. Remove remaining single-word bracket quoting [ColumnName] → ColumnName
    content = re.sub(r'\[(\w+)\]', r'\1', content)

    # 8b. Add semicolons to single-line INSERT...SELECT (not INSERT...VALUES)
    content = re.sub(
        r'^(INSERT\s+INTO\s+[^\n]*\bSELECT\b[^\n]*)(?<!;)\s*$',
        r'\1;',
        content,
        flags=re.MULTILINE | re.IGNORECASE
    )

    # 8c. Fix MSSQL DELETE alias syntax: "DELETE alias\nFROM table AS alias" → "DELETE FROM table AS alias"
    content = re.sub(
        r'\bDELETE\s+(\w+)\s*\n(\s*)FROM\s+(\S+)\s+AS\s+\1\b',
        r'DELETE FROM \3 AS \1',
        content,
        flags=re.IGNORECASE
    )

    # 9. datetime2(7) → TIMESTAMP(6)  (any remaining)
    content = re.sub(r'\bdatetime2\s*\(\s*7\s*\)', 'TIMESTAMP(6)', content, flags=re.IGNORECASE)

    # 10. GETDATE() → NOW()
    content = re.sub(r'\bGETDATE\s*\(\s*\)', 'NOW()', content, flags=re.IGNORECASE)

    # 11. CEILING() → CEIL()
    content = re.sub(r'\bCEILING\s*\(', 'CEIL(', content, flags=re.IGNORECASE)

    # 12. BEGIN TRAN[SACTION] → BEGIN;\n (preserve newline separation)
    content = re.sub(r'\bBEGIN\s+TRAN(?:SACTION)?\s*;?\s*\n', 'BEGIN;\n\n', content, flags=re.IGNORECASE)

    # 13. COMMIT (without ;) → COMMIT;
    content = re.sub(r'\bCOMMIT\b\s*(?!;)', 'COMMIT;', content, flags=re.IGNORECASE)

    # 14. RAISERROR('msg', n, m) → RAISE EXCEPTION 'msg';
    content = re.sub(
        r"RAISERROR\s*\(\s*'([^']+)'\s*,\s*\d+\s*,\s*\d+\s*\)\s*;?",
        r"RAISE EXCEPTION '\1';",
        content,
        flags=re.IGNORECASE
    )

    # 15. SELECT TOP N → SELECT (add LIMIT note)
    content = re.sub(r'\bSELECT\s+TOP\s+(\d+)\b', r'SELECT /* TOP \1 */', content, flags=re.IGNORECASE)

    # 16. ORDER BY NEWID() → ORDER BY random()
    content = re.sub(r'\bORDER\s+BY\s+NEWID\s*\(\s*\)', 'ORDER BY random()', content, flags=re.IGNORECASE)

    # 17. DataLoadSimulation function name mappings
    content = re.sub(
        r'\b(?:\[DataLoadSimulation\]|DataLoadSimulation)\.\[?GetStateProvinceID\]?\s*\(',
        'dataloadsimulation.get_state_province_id(',
        content,
        flags=re.IGNORECASE
    )
    content = re.sub(
        r'\b(?:\[DataLoadSimulation\]|DataLoadSimulation)\.\[?GetRandomCity\]?\b',
        'dataloadsimulation.get_random_city',
        content,
        flags=re.IGNORECASE
    )

    # 18. Add COMMIT if BEGIN present without matching COMMIT
    if re.search(r'\bBEGIN;\b', content, re.IGNORECASE):
        if not re.search(r'\bCOMMIT;', content, re.IGNORECASE):
            content = content.rstrip('\n;').rstrip() + '\n\nCOMMIT;\n'

    # 19. Clean up multiple blank lines
    content = re.sub(r'\n{3,}', '\n\n', content)

    return content.strip() + '\n'


if __name__ == '__main__':
    src = sys.argv[1]
    dst = sys.argv[2]
    with open(src, 'r', encoding='utf-8-sig') as f:  # utf-8-sig strips BOM
        raw = f.read()
    result = convert(raw)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, 'w', encoding='utf-8') as f:
        f.write(result)
    print(f"Converted: {src} → {dst}")
