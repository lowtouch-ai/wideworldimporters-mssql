#!/usr/bin/env python3
"""Convert WideWorldImporters T-SQL PostDeploymentScripts to PostgreSQL."""
import re, os, glob

SRC_DIR = "wwi-ssdt/wwi-ssdt/PostDeploymentScripts"
OUT_DIR = "postgres/seed"
os.makedirs(OUT_DIR, exist_ok=True)

SKIP = {
    "pds105-ins-dls-ficticiousnamepool.sql",
    "pds106-ins-dls-areacode.sql",
    "pds151-ins-post-app-cities.sql",
    "pds410-update-archive-tables.sql",
    "Script.PostDeployment1.sql",
}

# Scripts too complex for simple substitution — need procedural DO block
PROCEDURAL = {
    "pds220-ins-purchasing-suppliers.sql",
    "pds230-ins-sales-customers.sql",
    "pds240-ins-warehouse-stockitems.sql",
}


# ── type mapping ──────────────────────────────────────────────────────────────

def fix_type(t):
    t = t.strip().rstrip(';')
    for pat, rep in [
        (r'datetime2\s*\(\d+\)', 'timestamp'),
        (r'datetime2', 'timestamp'),
        (r'nvarchar\s*\(MAX\)', 'text'),
        (r'nvarchar\s*\((\d+)\)', r'varchar(\1)'),
        (r'nvarchar', 'text'),
        (r'varbinary\s*\(MAX\)', 'bytea'),
        (r'varbinary\s*\(\d+\)', 'bytea'),
        (r'\bint\b', 'integer'),
        (r'\bbit\b', 'boolean'),
    ]:
        t = re.sub(pat, rep, t, flags=re.IGNORECASE)
    return t


# ── identifier / value transforms ────────────────────────────────────────────

def fix_schema_table(sql):
    """Lower-case schema.table references."""
    SCHEMAS = r'Application|Sales|Purchasing|Warehouse|DataLoadSimulation|Sequences|Website|WebApi|Integration'
    # [Schema].[Table]
    sql = re.sub(r'\[(' + SCHEMAS + r')\]\.\[(\w+)\]',
                 lambda m: f"{m.group(1).lower()}.{m.group(2).lower()}", sql, flags=re.IGNORECASE)
    # [Schema].Table  (bracket on schema only)
    sql = re.sub(r'\[(' + SCHEMAS + r')\]\.(\w+)',
                 lambda m: f"{m.group(1).lower()}.{m.group(2).lower()}", sql, flags=re.IGNORECASE)
    # Schema.Table  (no brackets)
    sql = re.sub(r'\b(' + SCHEMAS + r')\.(\w+)',
                 lambda m: f"{m.group(1).lower()}.{m.group(2).lower()}", sql, flags=re.IGNORECASE)
    return sql


def fix_columns(sql):
    """[ColumnName] → "ColumnName" preserving case."""
    return re.sub(r'\[([A-Za-z_]\w*)\]', r'"\1"', sql)


def fix_dates(sql):
    sql = re.sub(r"'(\d{4})(\d{2})(\d{2})'", r"'\1-\2-\3'", sql)
    sql = re.sub(r"'\d{4}-12-31\s+23:59:59\.\d+'", "'9999-12-31 23:59:59.999999'", sql)
    return sql


def fix_binary(sql):
    sql = re.sub(r'\b0x[0-9A-Fa-f]{65,}\b', 'NULL', sql)         # geography → NULL
    sql = re.sub(r'\b0x([0-9A-Fa-f]{64})\b', r"'\\x\1'::bytea", sql)  # password hash
    sql = re.sub(r'\b0x([0-9A-Fa-f]+)\b', r"'\\x\1'::bytea", sql)     # any other hex
    return sql


def fix_casts(sql):
    sql = re.sub(r'\bCAST\((.+?) AS datetime2\(\d+\)\)', r'CAST(\1 AS timestamp)', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bCAST\((.+?) AS nvarchar\((\d+)\)\)', r'CAST(\1 AS varchar(\2))', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bCAST\((.+?) AS nvarchar\)', r'CAST(\1 AS text)', sql, flags=re.IGNORECASE)
    return sql


def fix_dls_calls(sql):
    """Replace DataLoadSimulation helper functions with inline subqueries."""
    lookup = [
        (r'GetPersonID', 'application.people', '"PersonID"', '"FullName"'),
        (r'GetSupplierCategoryID', 'purchasing.suppliercategories', '"SupplierCategoryID"', '"SupplierCategoryName"'),
        (r'GetDeliveryMethodID', 'application.deliverymethods', '"DeliveryMethodID"', '"DeliveryMethodName"'),
        (r'GetTransactionTypeID', 'application.transactiontypes', '"TransactionTypeID"', '"TransactionTypeName"'),
        (r'GetPaymentMethodID', 'application.paymentmethods', '"PaymentMethodID"', '"PaymentMethodName"'),
        (r'GetCustomerCategoryID', 'sales.customercategories', '"CustomerCategoryID"', '"CustomerCategoryName"'),
        (r'GetBuyingGroupID', 'sales.buyinggroups', '"BuyingGroupID"', '"BuyingGroupName"'),
        (r'GetStateProvinceID', 'application.stateprovinces', '"StateProvinceID"', '"StateProvinceCode"'),
    ]
    SCHEMAS = r'(?:\[?DataLoadSimulation\]?\.)?'
    for func, tbl, id_col, name_col in lookup:
        sql = re.sub(
            SCHEMAS + r'\[?' + func + r'\]?\s*\(\s*\'([^\']+)\'\s*\)',
            lambda m, t=tbl, ic=id_col, nc=name_col:
                f"(SELECT {ic} FROM {t} WHERE {nc} = '{m.group(1)}' LIMIT 1)",
            sql, flags=re.IGNORECASE)
    return sql


def strip_boilerplate(sql):
    sql = sql.lstrip('﻿')
    sql = re.sub(r"PRINT\s+N?'[^']*'\s*\n?", '', sql, flags=re.IGNORECASE)
    sql = re.sub(r'^\s*GO\s*$', '', sql, flags=re.MULTILINE)
    sql = re.sub(r'^\s*SET\s+NOCOUNT\s+ON\s*;?\s*$', '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r'^\s*SET\s+IDENTITY_INSERT\s+\S+\s+(?:ON|OFF)\s*;?\s*$', '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r"^\s*BEGIN\s+TRAN(?:SACTION)?\s*;?\s*$", '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r"^\s*COMMIT\s+TRAN(?:SACTION)?\s*;?\s*$", '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r"^\s*COMMIT\s*;?\s*$", '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r"\bN'", "'", sql)
    return sql


# ── simple scripts: substitute @var literals directly ────────────────────────

def convert_simple(sql):
    """For scripts whose only vars are timestamp/simple scalars — inline them."""
    # Handle SELECT @var = col FROM table WHERE ... (resolve at convert time)
    # For known patterns, substitute hardcoded values
    SELECT_RESOLVES = {
        'countryidus': '230',  # United States
    }
    var_values = {}

    # First pass: capture SELECT @var = ... assignments (keyed lowercase)
    def capture_select_assign(m):
        varname = m.group(1).lower()
        if varname in SELECT_RESOLVES:
            var_values[varname] = SELECT_RESOLVES[varname]
        return ''  # remove the SELECT assignment line
    sql = re.sub(
        r'^\s*SELECT\s+@(\w+)\s*=\s*"?\w+"?\s+FROM\s+[^\n]+$',
        capture_select_assign, sql, flags=re.MULTILINE | re.IGNORECASE)

    # Second pass: collect DECLARE @var type = value (keyed lowercase, skip if already resolved)
    def collect(m):
        name = m.group(1).lower()
        if name not in var_values:  # don't overwrite SELECT-resolved values
            raw = (m.group(2) or 'NULL').strip().rstrip(';')
            raw = re.sub(r"'(\d{4})(\d{2})(\d{2})'", r"'\1-\2-\3'", raw)
            raw = re.sub(r"'99991231 23:59:59\.\d+'", "'9999-12-31 23:59:59.999999'", raw)
            var_values[name] = raw
        return ''  # remove the DECLARE line
    sql = re.sub(
        r'^\s*DECLARE\s+@(\w+)\s+(?:AS\s+)?[\w\(\), ]+?(?:\s*=\s*(.+?))?;?\s*$',
        collect, sql, flags=re.MULTILINE | re.IGNORECASE)

    # Replace @varname with their literal values (var_values keyed lowercase)
    for name, val in sorted(var_values.items(), key=lambda x: -len(x[0])):
        sql = re.sub(r'(?<!\w)@' + re.escape(name) + r'(?!\w)', val, sql, flags=re.IGNORECASE)

    # Replace DataLoadSimulation helper function calls
    sql = fix_dls_calls(sql)

    # Fix INSERT (missing INTO)
    sql = re.sub(r'\bINSERT\s+(\w+\.)', r'INSERT INTO \1', sql, flags=re.IGNORECASE)
    # Fix SET @leftover = ... (shouldn't happen in simple scripts)
    sql = re.sub(r'^\s*SET\s+@\w+\s*=.*$', '', sql, flags=re.MULTILINE | re.IGNORECASE)
    return sql.strip() + '\n'


# ── procedural scripts: proper DO $body$...$body$ block ──────────────────────

def convert_procedural(sql):
    """For scripts with real T-SQL procedural logic."""
    declare_lines = []
    used_vars = {}

    def collect_declare(m):
        varname = m.group(1).lower()
        pg_type = fix_type(m.group(2))
        raw = (m.group(3) or 'NULL').strip().rstrip(';')
        raw = fix_dates(f"'{raw}'" if re.match(r'\d{8}$', raw) else raw)
        raw = raw.strip()
        # Boolean defaults: 0/1 → false/true
        if 'boolean' in pg_type and raw in ('0', '1'):
            raw = 'false' if raw == '0' else 'true'
        pg_name = f"v_{varname}"
        used_vars[m.group(1)] = pg_name
        declare_lines.append(f"    {pg_name} {pg_type} := {raw};")
        return ''

    sql = re.sub(
        r'^\s*DECLARE\s+@(\w+)\s+(?:AS\s+)?([\w\(\), ]+?)(?:\s*=\s*(.+?))?;?\s*$',
        collect_declare, sql, flags=re.MULTILINE | re.IGNORECASE)

    # Replace @varname
    for orig, pg in sorted(used_vars.items(), key=lambda x: -len(x[0])):
        sql = re.sub(r'(?<!\w)@' + re.escape(orig) + r'(?!\w)', pg, sql, flags=re.IGNORECASE)

    # SET v_var = expr  →  v_var := expr;
    sql = re.sub(r'\bSET\s+(v_\w+)\s*=\s*', r'\1 := ', sql, flags=re.IGNORECASE)

    # SELECT @var = col FROM → SELECT col INTO v_var FROM
    sql = re.sub(r'\bSELECT\s+(v_\w+)\s*=\s*(\w+)\s+FROM',
                 r'SELECT \2 INTO \1 FROM', sql, flags=re.IGNORECASE)

    # String concat: + → ||
    sql = re.sub(r"'(\s*)\+(\s*)", r"'\1||\2", sql)
    sql = re.sub(r"(\s*)\+(\s*)'", r"\1||\2'", sql)
    sql = re.sub(r'(v_\w+)\s*\+\s*(v_\w+)', r'\1 || \2', sql)
    sql = re.sub(r"(v_\w+)\s*\+\s*'", r"\1 || '", sql)
    sql = re.sub(r"'\s*\+\s*(v_\w+)", r"' || \1", sql)

    # Fix INSERT (missing INTO)
    sql = re.sub(r'\bINSERT\s+(\w+\.)', r'INSERT INTO \1', sql, flags=re.IGNORECASE)

    # Remove EXEC DataLoadSimulation.GetRandomCity (leave v_mycityid as NULL)
    sql = re.sub(
        r'EXEC\s+\[?DataLoadSimulation\]?\.\[?GetRandomCity\]?.*?(?=\n\s*(?:v_|\nSET|INSERT|/\*))',
        '', sql, flags=re.IGNORECASE | re.DOTALL)

    # Replace DataLoadSimulation function calls
    sql = fix_dls_calls(sql)

    # Add ; after each INSERT VALUES block (handles comments/blank lines between statements)
    # Strategy: find ) at end of a line, then find the next non-blank non-comment line
    lines = sql.split('\n')
    result = []
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        result.append(line)
        if stripped.endswith(')') and not stripped.rstrip(')').rstrip().endswith(','):
            # Look ahead for next meaningful line
            for j in range(i + 1, min(i + 10, len(lines))):
                ahead = lines[j].strip()
                if not ahead or ahead.startswith('--') or ahead.startswith('/*') or ahead.startswith('*'):
                    continue
                if re.match(r'^(v_\w+\s*:=|INSERT|UPDATE|END\s*;)', ahead, re.IGNORECASE):
                    result[-1] = line.rstrip() + ';'
                break
    sql = '\n'.join(result)

    # := lines that don't end with ;
    sql = re.sub(r'(:=[^;\n]+?)(\n\s*(?:v_|INSERT|UPDATE|END\s*;|SELECT))',
                 r'\1;\2', sql)

    # SELECT INTO lines need ; (they end in WHERE ... or FROM ... clauses)
    sql = re.sub(r'(SELECT\s+\w+\s+INTO\s+v_\w+\s+FROM\s+[^\n;]+?)(\n\s*(?:v_|INSERT|UPDATE|SELECT|END\s*;))',
                 r'\1;\2', sql, flags=re.IGNORECASE)

    # Remove leftover EXEC parameter lines (@ lines)
    sql = re.sub(r'^\s*,?\s*@\w+\s*=.*OUTPUT.*$', '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r'^\s*@\w+\s*=.*$', '', sql, flags=re.MULTILINE)

    # T-SQL → PL/pgSQL
    sql = re.sub(r'\bRAISERROR\s*\(([^,]+),\s*\d+,\s*\d+\)',
                 lambda m: f"RAISE EXCEPTION {m.group(1)}", sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bSELECT\s+TOP\s*\(?\s*1\s*\)?\s+', 'SELECT ', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bORDER\s+BY\s+NEWID\(\)', 'ORDER BY random()', sql, flags=re.IGNORECASE)

    body = sql.strip()
    decls = '\n'.join(declare_lines)
    # Use $body$ delimiter to avoid conflicts with $$ in string literals
    return f"DO $body$\nDECLARE\n{decls}\nBEGIN\n{body}\nEND;\n$body$;\n"


# ── main conversion ───────────────────────────────────────────────────────────

def convert(sql, filename):
    sql = strip_boilerplate(sql)
    sql = fix_schema_table(sql)
    sql = fix_columns(sql)
    sql = fix_dates(sql)
    sql = fix_binary(sql)
    sql = fix_casts(sql)
    sql = re.sub(r'\n{3,}', '\n\n', sql)

    if filename in PROCEDURAL:
        return convert_procedural(sql)
    else:
        return convert_simple(sql)


files = sorted(glob.glob(f"{SRC_DIR}/pds*.sql"))
converted, skipped = [], []

for filepath in files:
    filename = os.path.basename(filepath)
    if filename in SKIP:
        skipped.append(filename)
        continue
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        raw = f.read()
    out = convert(raw, filename)
    out_path = os.path.join(OUT_DIR, filename)
    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(out)
    converted.append(filename)
    print(f"  ✓ {filename}")

print(f"\nConverted {len(converted)} → {OUT_DIR}/")
print(f"Skipped: {', '.join(skipped)}")
