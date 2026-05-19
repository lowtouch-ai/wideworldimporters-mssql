# Session 16: PostDeploymentScripts Conversion — Issues & Fixes

Tracks bugs encountered in `scripts/convert_pds.py` and the manual conversions during the T-SQL → PostgreSQL migration of `wwi-ssdt/wwi-ssdt/PostDeploymentScripts/`.

---

## 1. UTF-8 BOM prevented first-line `PRINT` conversion

**File:** `scripts/convert_pds.py`

**Issue:** The script opened source files with `open(src, 'r')` (default encoding). MSSQL SSDT exports files with a UTF-8 BOM (`\xef\xbb\xbf`). The BOM was prepended to the first line, so the regex `r'^\s*PRINT\s+'` never matched line 1 — that `PRINT` statement passed through unconverted.

**Fix:** Changed the open call to `encoding='utf-8-sig'`, which automatically strips the BOM before the content is read.

```python
# Before
with open(src, 'r') as f:

# After
with open(src, 'r', encoding='utf-8-sig') as f:
```

---

## 2. Removing `GO` left INSERT blocks without statement terminators

**File:** `scripts/convert_pds.py`

**Issue:** The script replaced `GO` with an empty string. In MSSQL, `GO` is the batch terminator — it implicitly ends any unterminated statement above it. Many INSERT blocks had no `;` before the `GO`. After removing `GO`, those statements had no terminator, causing syntax errors in PostgreSQL.

**Fix:** Replaced `GO` with `;` instead of deleting it, so the preceding statement gets a proper terminator.

```python
# Before
line = re.sub(r'^\s*GO\s*$', '', line)

# After
line = re.sub(r'^\s*GO\s*$', ';', line)
```

---

## 3. Non-geography hex literals converted to NULL

**File:** `scripts/convert_pds.py`, function `convert_hex_literal()`

**Issue:** The function treated every `0x...` literal as a geography binary and converted it to PostGIS or `NULL`. Password hash columns (e.g., `HashedPassword = 0x9AF...`) were incorrectly nulled out.

**Root cause:** MSSQL geography binary always begins with `E6100000` (the little-endian SRID 4326). Other binary literals (password hashes, image data) do not share this prefix.

**Fix:** Added a prefix check. Only values starting with `e6100000` are treated as geography. All others become `decode('...', 'hex')` (PostgreSQL `bytea`).

```python
def convert_hex_literal(hex_str):
    if hex_str.lower().startswith('e6100000'):
        return convert_geo_point(hex_str)       # PostGIS path
    return f"decode('{hex_str}', 'hex')"         # Generic bytea
```

---

## 4. Table names kept MSSQL CamelCase after schema conversion

**File:** `scripts/convert_pds.py`

**Issue:** The script lowercased schema prefixes (`[Sales].` → `sales.`) but left table names in their original MSSQL casing (`sales.OrderLines`, `sales.Customers`). PostgreSQL table names in this project use snake_case or all-lowercase-joined forms (`sales.orderlines`, `application.delivery_methods`), which do not follow a single mechanical rule from the MSSQL names.

**Fix:** Added a `TABLE_MAP` dictionary mapping 50+ MSSQL qualified names to their PostgreSQL equivalents, applied after the schema prefix is lowercased.

```python
TABLE_MAP = {
    'application.deliverymethods':      'application.delivery_methods',
    'application.stateprovinces':       'application.state_provinces',
    'purchasing.suppliercategories':    'purchasing.supplier_categories',
    'warehouse.packagetypes':           'warehouse.package_types',
    'warehouse.stockgroups':            'warehouse.stock_groups',
    # ... 45+ more entries
}
```

---

## 5. Unbracketed `Schema.Table` references not converted

**File:** `scripts/convert_pds.py`

**Issue:** The de-bracketing rule (`[Schema].[Table]` → `schema.table`) only matched the bracketed form. References written without brackets — e.g., `FROM Warehouse.StockGroups` — passed through unchanged with wrong casing.

**Fix:** Added a second rule (7b) that matches any identifier using a known WWI schema name (`Application`, `Sales`, `Purchasing`, `Warehouse`, `DataLoadSimulation`, etc.) followed by `.TableName`, case-insensitively, and routes it through `TABLE_MAP`.

```python
# Rule 7b: unbracketed Schema.Table
KNOWN_SCHEMAS = r'(?:Application|Sales|Purchasing|Warehouse|DataLoadSimulation|...)'
pattern = re.compile(rf'\b({KNOWN_SCHEMAS})\.(\w+)', re.IGNORECASE)
```

---

## 6. `[ColumnName]` brackets in column lists not removed

**File:** `scripts/convert_pds.py`

**Issue:** After the schema.table de-bracketing pass, individual column-name brackets remained — e.g., `[StockItemID]`, `[OrderID]`. These are valid in MSSQL but cause syntax errors in PostgreSQL.

**Fix:** Added rule 7c: a simple regex that strips any remaining `[word]` brackets (single-word identifiers only, to avoid touching string literals that happen to contain square brackets).

```python
# Rule 7c: remaining [SingleWordIdentifier] brackets
line = re.sub(r'\[(\w+)\]', r'\1', line)
```

---

## 7. `[E]` inside a string literal was bracket-stripped

**File:** `pds140-ins-app-stateprovinces.sql`

**Issue:** The bracket removal rule (rule 7c above) doesn't parse string context. The state name `'Massachusetts[E]'` had `[E]` stripped, producing `'MassachusettsE'` — a data corruption bug, not a syntax error, so it would have been silently wrong.

**Fix:** The script has no string-aware bracket stripping. This file was rewritten manually. The correct row is:

```sql
, (22, 'MA', 'Massachusetts[E]', v_country_id_us, 'New England', NULL, 6692824, ...)
```

**Mitigation note:** A future improvement to `convert_pds.py` would be to skip `\[(\w+)\]` matches when the position is inside a single-quoted string literal.

---

## 8. `DELETE alias FROM table AS alias` MSSQL-only syntax

**File:** `scripts/convert_pds.py`, `pds151-ins-post-app-cities.sql`

**Issue:** MSSQL allows naming the target alias in a `DELETE` statement: `DELETE c FROM application.cities AS c WHERE ...`. PostgreSQL requires the table reference be in the `FROM` clause: `DELETE FROM application.cities AS c WHERE ...`.

**Fix:** Added rule 8c using a multi-line regex to detect the pattern and rewrite it:

```python
# Rule 8c: DELETE alias FROM table AS alias → DELETE FROM table AS alias
line = re.sub(
    r'DELETE\s+(\w+)\s*\n(\s*)FROM\s+(\S+)\s+AS\s+\1\b',
    r'DELETE FROM \3 AS \1',
    line, flags=re.IGNORECASE
)
```

---

## 9. Single-line `INSERT INTO ... SELECT ...` missing semicolons

**File:** `scripts/convert_pds.py`, multiple files

**Issue:** Several files used the pattern `INSERT INTO schema.table (...) SELECT ...` on a single line (no trailing `;` and no following `GO`). After GO-removal the statements had no terminator.

**Fix:** Added rule 8b: a regex that appends `;` to any line matching the INSERT...SELECT single-line pattern when no semicolon is already present.

```python
# Rule 8b: single-line INSERT INTO ... SELECT ... without semicolon
line = re.sub(
    r'^(INSERT\s+INTO\s+\S+.*SELECT.+[^;])\s*$',
    r'\1;',
    line, flags=re.IGNORECASE
)
```

---

## 10. `pds240` agent hit output token limit

**File:** `pds240-ins-warehouse-stockitems.sql`

**Issue:** This file requires a DO block wrapping 219 INSERT rows plus 22 variable lookups. The agent tasked with the conversion exceeded the 32,000 output token maximum and terminated without producing output.

**Fix:** Ran a Python inline script directly via `bash` instead. The script added the DO block header, declared 22 variables, inserted the `SELECT INTO` lookups, and replaced all `@VariableName` references with `v_variable_name` throughout the 282-line body.

A `SyntaxWarning` about `\e` in an f-string (from `\echo` inside a non-raw string) was emitted but was non-fatal — the output was written correctly.

---

## 11. `BEGIN TRANSACTION` left no blank line before `INSERT INTO`

**File:** `scripts/convert_pds.py`

**Issue:** The regex replacing `BEGIN TRANSACTION` with `BEGIN;` used `\n` at the end but the surrounding whitespace varied. In some files the converted `BEGIN;` ended up immediately adjacent to the next `INSERT INTO` with no blank line, making the output harder to read and occasionally confusing statement boundaries.

**Fix:** Updated the replacement to emit `BEGIN;\n\n` (two newlines) to ensure a blank line always follows:

```python
line = re.sub(
    r'\bBEGIN\s+TRAN(?:SACTION)?\s*;?\s*\n',
    'BEGIN;\n\n',
    line, flags=re.IGNORECASE
)
```

---

## 12. MSSQL geography POINT binary — lat/lon byte order is swapped vs PostGIS

**Affects:** `pds150-ins-app-cities.sql`, `pds220-ins-purchasing-suppliers.sql`, `pds230-ins-sales-customers.sql`, `pds270-ins-app-systemparameters.sql`

**Issue:** MSSQL stores `geography::Point(lat, lon, 4326)` in binary as:

```
E6100000  — SRID 4326 (little-endian)
01        — version
0C        — single-point property flags
[8 bytes] — latitude (little-endian double)
[8 bytes] — longitude (little-endian double)
```

PostGIS WKB POINT format is:

```
01        — little-endian marker
01000000  — geometry type: POINT
[8 bytes] — longitude (little-endian double)
[8 bytes] — latitude (little-endian double)
```

The lat/lon order is **reversed** between the two formats. Naively copying the MSSQL byte sequence into PostGIS produces a point reflected across the diagonal — coordinates swap hemispheres.

**Fix:** In `convert_hex_literal()`, extract the lat bytes (positions 12–27) and lon bytes (positions 28–43) from the MSSQL binary, then reconstruct as `0101000000 + lon_bytes + lat_bytes`:

```python
mssql_hex = hex_str.lower()
lat_hex = mssql_hex[12:28]   # bytes 6–13: latitude
lon_hex = mssql_hex[28:44]   # bytes 14–21: longitude
wkb = '0101000000' + lon_hex + lat_hex
return f"ST_GeomFromWKB(decode('{wkb}', 'hex'), 4326)::geography"
```

For `geography::Point(lat, lon, srid)` calls (inline, not binary), the fix is:

```sql
-- MSSQL
geography::Point(37.765786, -122.504086, 4326)

-- PostgreSQL (lon, lat order for ST_MakePoint)
ST_SetSRID(ST_MakePoint(-122.504086, 37.765786), 4326)::geography
```

---

## 13. Polygon geography (country borders) cannot be auto-converted

**File:** `pds110-ins-app-countries.sql`, `pds142-upd-app-stateprovinces-borders.sql`

**Issue:** Country border geometries are multi-polygon WKB stored in MSSQL's proprietary geography binary format (begins `E61000000104...`). The conversion logic handles only single POINT geometry. Attempting to blindly remap the byte layout produces invalid PostGIS geometry.

**Fix (pds110):** Set the `Border` column to `NULL` with an inline TODO comment preserving the first 20 hex chars for identification:

```sql
NULL /* TODO: convert MSSQL geography binary 0xE61000000104... to PostGIS */
```

**Fix (pds142):** State border WKB was converted using PostGIS `ST_GeomFromWKB` after stripping the MSSQL 6-byte header (`E6100000` SRID prefix + `01` version + flags). Verified against a PostGIS instance.

**Long-term:** A dedicated geometry conversion tool (e.g., using `pyproj` + `shapely` or `ogr2ogr`) would be needed to properly re-serialize all polygon geometries.
