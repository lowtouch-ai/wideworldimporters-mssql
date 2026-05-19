#!/usr/bin/env python3
"""
Post-process converted seed files to fix remaining PostgreSQL compatibility issues.
"""
import re, os, glob

SEED_DIR = "postgres/seed"

# Boolean columns per table (schema.table -> set of lowercase column names)
BOOL_COLS = {
    "application.people": {"ispermittedtologon","isexternallogonprovider","issystemuser","isemployee","issalesperson"},
    "purchasing.purchaseorderlines": {"isorderlinefinalized"},
    "purchasing.purchaseorders": {"isorderfinalized"},
    "purchasing.suppliertransactions": {"isfinalized"},
    "sales.customers": {"isstatementsent","isoncredithold"},
    "sales.customertransactions": {"isfinalized"},
    "sales.invoices": {"iscreditnote"},
    "sales.orders": {"isundersupplybackordered"},
    "warehouse.stockitems": {"ischillerstock"},
    "warehouse.vehicletemperatures": {"iscompressed"},
}


def strip_identifier_quotes(sql):
    """Remove double-quotes from identifiers. Safe because string literals use single quotes."""
    # Only strip double-quoted identifiers (word chars only), not JSON string content
    # JSON strings like "theme": use double quotes — but they're inside single-quoted strings
    # So we only strip double-quoted identifiers that appear OUTSIDE of single-quoted strings
    result = []
    i = 0
    in_single = False
    while i < len(sql):
        c = sql[i]
        if c == "'" and not in_single:
            in_single = True
            result.append(c)
        elif c == "'" and in_single:
            in_single = False
            result.append(c)
        elif c == '"' and not in_single:
            # Consume the quoted identifier
            j = i + 1
            while j < len(sql) and sql[j] != '"':
                j += 1
            result.append(sql[i+1:j])  # identifier without quotes
            i = j  # skip closing "
        else:
            result.append(c)
        i += 1
    return ''.join(result)


def fix_multi_insert_semicolons(sql):
    """Add ; after each INSERT...VALUES block when followed by another INSERT."""
    # Match: closing ) of VALUES block NOT followed by ; then followed by INSERT
    sql = re.sub(r'\)\s*\n(\s*INSERT\s+INTO)', r');\n\1', sql, flags=re.IGNORECASE)
    return sql


def fix_bool_in_insert(sql):
    """
    For INSERT INTO schema.table (col, ...) VALUES (...), convert 0/1 -> false/true
    at positions that are boolean columns.
    """
    # Find each INSERT block: INSERT INTO tbl (cols) VALUES (row),(row),...;
    insert_re = re.compile(
        r'(INSERT\s+INTO\s+(\S+)\s*\(([^)]+)\)\s*\n?VALUES?\s*\n?)(.*?)(?=;\s*(?:\n|$)|\Z)',
        re.IGNORECASE | re.DOTALL
    )

    def patch_insert(m):
        header = m.group(1)
        tbl = m.group(2).lower().rstrip(';').strip()
        col_str = m.group(3)
        values_body = m.group(4)

        bool_set = BOOL_COLS.get(tbl, set())
        if not bool_set:
            return m.group(0)

        cols = [c.strip().lower() for c in col_str.split(',')]
        bool_pos = {i for i, c in enumerate(cols) if c in bool_set}
        if not bool_pos:
            return m.group(0)

        # Use depth-aware row finder to handle () inside quoted strings
        rows_info = find_value_rows(values_body)
        if not rows_info:
            return m.group(0)

        chars = list(values_body)
        offset = 0
        for start, end, content in rows_info:
            vals = split_values(content)
            for i in bool_pos:
                if i < len(vals):
                    v = vals[i].strip()
                    if v == '0':
                        vals[i] = ' false'
                    elif v == '1':
                        vals[i] = ' true'
            new_row = '(' + ','.join(vals) + ')'
            s, e = start + offset, end + 1 + offset
            chars[s:e] = list(new_row)
            offset += len(new_row) - (end + 1 - start)
        return header + ''.join(chars)

    return insert_re.sub(patch_insert, sql)


def find_value_rows(text):
    """Return (start, end_inclusive, content) for each top-level (...) in text."""
    rows, i = [], 0
    while i < len(text):
        if text[i] == '(':
            depth, in_str, j = 1, False, i + 1
            while j < len(text) and depth > 0:
                c = text[j]
                if c == "'" and not in_str:
                    in_str = True
                elif c == "'" and in_str:
                    in_str = False
                elif not in_str:
                    if c == '(':
                        depth += 1
                    elif c == ')':
                        depth -= 1
                j += 1
            rows.append((i, j - 1, text[i + 1:j - 1]))
            i = j
        else:
            i += 1
    return rows


def split_values(row):
    """Split comma-separated VALUES row respecting single-quoted strings."""
    parts, current, in_str = [], [], False
    for c in row:
        if c == "'" and not in_str:
            in_str = True
            current.append(c)
        elif c == "'" and in_str:
            in_str = False
            current.append(c)
        elif c == ',' and not in_str:
            parts.append(''.join(current))
            current = []
        else:
            current.append(c)
    if current:
        parts.append(''.join(current))
    return parts


def fix_bytea_in_text_columns(sql):
    """Remove bytea literals from city Location and state Border (TEXT columns, no PostGIS)."""
    # Cities: location column gets bytea geography data → NULL
    sql = re.sub(
        r"(application\.(?:cities|stateprovinces)[^;]*?'\\x[0-9a-fA-F]+'::bytea)",
        lambda m: re.sub(r"'\\x[0-9a-fA-F]+'::bytea", 'NULL', m.group(0)),
        sql, flags=re.IGNORECASE | re.DOTALL)
    return sql


def fix_geography_declare(sql):
    """Replace geography type with TEXT in DO block DECLARE sections."""
    return re.sub(r'\bGEOGRAPHY\b', 'TEXT', sql, flags=re.IGNORECASE)


def fix_exec_calls(sql):
    """Remove remaining EXEC DataLoadSimulation.* calls and orphaned OUTPUT parameter lines."""
    sql = re.sub(
        r'^\s*EXEC\s+\S+getrandomcity[^\n]*(?:\n\s*,[^\n]*)*\n?',
        '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = re.sub(r'^\s*EXEC\s+\S+\s*\n(?:(?:,\s*@\w+[^\n]*\n))*', '', sql,
                 flags=re.MULTILINE | re.IGNORECASE)
    # Remove orphaned OUTPUT parameter lines left after EXEC removal (e.g. "@CityID = NULL OUTPUT")
    sql = re.sub(r'^\s*,?\s*@\w+\s*=\s*[^\n]*OUTPUT[^\n]*\n?', '', sql,
                 flags=re.MULTILINE | re.IGNORECASE)
    return sql


def fix_select_assign(sql):
    """Fix T-SQL SELECT @var = col FROM that didn't get converted cleanly."""
    # Double INTO: SELECT col INTO v_x INTO v_x FROM → SELECT col INTO v_x FROM
    sql = re.sub(r'SELECT\s+(\w+)\s+INTO\s+(v_\w+)\s+INTO\s+\2\s+FROM',
                 r'SELECT \1 INTO \2 FROM', sql, flags=re.IGNORECASE)
    # Bare assignment: SELECT v_var = col FROM → SELECT col INTO v_var FROM
    sql = re.sub(r'SELECT\s+(v_\w+)\s*=\s*(\w+)\s+FROM',
                 r'SELECT \2 INTO \1 FROM', sql, flags=re.IGNORECASE)
    return sql


def fix_pds220(sql):
    """Fix T-SQL UPDATE ... FROM ... INNER JOIN and DATEADD in pds220."""
    # DATEADD(minute, expr, col) → col + (expr * INTERVAL '1 minute')
    sql = re.sub(
        r"DATEADD\s*\(\s*minute\s*,\s*([^,]+?)\s*,\s*(v_\w+)\s*\)",
        r"(\2 + (\1) * INTERVAL '1 minute')",
        sql, flags=re.IGNORECASE)
    # T-SQL: UPDATE alias SET alias.col = ... FROM tbl AS alias JOIN ...
    # → PostgreSQL: UPDATE tbl AS alias SET col = ... FROM ...
    sql = re.sub(
        r'UPDATE\s+(\w+)\s+SET\s+\1\.(\w+)\s*=\s*(\S+)\s*,\s*\1\.(\w+)\s*=\s*([^\n]+)\n'
        r'\s*FROM\s+(purchasing\.\w+)\s+AS\s+\1\s*\n'
        r'\s*INNER JOIN\s+(application\.\w+)\s+AS\s+(\w+)\s*\n'
        r'\s*ON\s+\1\.(\w+)\s*=\s*\8\.(\w+)',
        lambda m: (
            f"UPDATE {m.group(6)} AS {m.group(1)}\n"
            f"   SET {m.group(2)} = {m.group(3)},\n"
            f"       {m.group(4)} = {m.group(5)}\n"
            f"  FROM {m.group(7)} AS {m.group(8)}\n"
            f" WHERE {m.group(1)}.{m.group(9)} = {m.group(8)}.{m.group(10)}"
        ),
        sql, flags=re.IGNORECASE)
    # RAND() → RANDOM()
    sql = re.sub(r'\bRAND\(\)', 'RANDOM()', sql, flags=re.IGNORECASE)
    return sql


def fix_pds240_semicolons(sql):
    """Add missing semicolons to SELECT INTO lines in pds240."""
    lines = sql.split('\n')
    result = []
    for i, line in enumerate(lines):
        stripped = line.rstrip()
        # SELECT ... INTO v_... FROM ... without trailing ;
        if re.match(r"^\s*SELECT\s+\w+\s+INTO\s+v_\w+\s+FROM\s+", stripped, re.IGNORECASE):
            if not stripped.endswith(';'):
                stripped = stripped + ';'
        result.append(stripped)
    return '\n'.join(result)


def fix_pds270(sql):
    """Fix pds270 geography value and orphaned parameter lines."""
    # Remove TEXT::Point(...) geography → NULL
    sql = re.sub(r'TEXT::Point\s*\([^)]+\)', 'NULL', sql, flags=re.IGNORECASE)
    return sql


def fix_pds400(sql):
    """Convert T-SQL IF block to PL/pgSQL DO block."""
    # The file already has the DO $body$ block from convert-pds.py
    # Just ensure RAISERROR and other T-SQL leftovers are fixed
    sql = re.sub(r'\bRAISERROR\s*\(([^,]+),\s*\d+,\s*\d+\)',
                 lambda m: f"RAISE EXCEPTION {m.group(1)}", sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bSELECT\s+TOP\s*\(?\s*1\s*\)?\s+', 'SELECT ', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bORDER\s+BY\s+NEWID\(\)', 'ORDER BY random()', sql, flags=re.IGNORECASE)
    # Ensure LIMIT 1 is added after SELECT without one (for ORDER BY random())
    sql = re.sub(r'(ORDER BY random\(\))\s*(?!LIMIT)', r'\1\nLIMIT 1', sql, flags=re.IGNORECASE)
    # If the block lacks END IF / END wrap, reconstruct it
    if 'DO $body$' in sql and 'END IF' not in sql:
        # Already has DO $body$ BEGIN, RAISE EXCEPTION, INSERT — add END IF; END; $body$;
        sql = sql.rstrip().rstrip(';')
        sql += '\nEND IF;\nEND;\n$body$;'
    return sql


def process_file(path):
    filename = os.path.basename(path)
    with open(path) as f:
        sql = f.read()

    sql = strip_identifier_quotes(sql)
    # Remove stray SELECT @var = ... lines not inside DO blocks
    sql = re.sub(r'^\s*SELECT\s+\w+\s*=\s*\w+\s+FROM[^\n]+\n?', '', sql, flags=re.MULTILINE | re.IGNORECASE)
    sql = fix_multi_insert_semicolons(sql)
    sql = fix_bytea_in_text_columns(sql)
    sql = fix_bool_in_insert(sql)
    sql = fix_geography_declare(sql)
    sql = fix_exec_calls(sql)
    sql = fix_select_assign(sql)

    if 'pds220' in filename:
        sql = fix_pds220(sql)
    if 'pds240' in filename:
        sql = fix_pds240_semicolons(sql)
    if 'pds270' in filename:
        sql = fix_pds270(sql)

    # Ensure file ends with semicolon
    sql = sql.rstrip()
    if sql and not sql.endswith(';'):
        sql += ';'
    sql = re.sub(r'\n{3,}', '\n\n', sql)

    if 'pds400' in filename:
        sql = fix_pds400(sql)

    with open(path, 'w') as f:
        f.write(sql.strip() + '\n')


files = sorted(glob.glob(f"{SEED_DIR}/pds*.sql"))
for f in files:
    process_file(f)
    print(f"  ✓ {os.path.basename(f)}")

print(f"\nPost-processed {len(files)} files.")
