---
description: Convert a MSSQL VIEW (.sql file or folder) to a PostgreSQL CREATE OR REPLACE VIEW, writing output to postgres/<Schema>/Views/.
argument-hint: <view-sql-file-or-folder>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL View Conversion

Given `$ARGUMENTS` (a `.sql` file or a directory):

## Step 1 — Collect files to convert

- If `$ARGUMENTS` is a `.sql` file → convert that one file.
- If `$ARGUMENTS` is a directory → glob `**/*.sql` inside it and convert every file found.
- If a file does not contain `CREATE VIEW`, skip it and print a warning.

## Step 2 — For each file, apply these conversion rules

### Identifiers
- Strip square-bracket quoting everywhere: `[WebApi].[Customers]` → `webapi.customers`.
- Lowercase schema and view names.
- **Preserve original casing for column names and aliases.**
- Remove `GO` statement separators.
- Replace `CREATE VIEW` / `CREATE   VIEW` (any extra whitespace) with `CREATE OR REPLACE VIEW`.

### Column alias syntax
MSSQL allows `Alias = expression` — PostgreSQL does not. Convert to standard SQL:
```sql
-- MSSQL
PostalCity = pc.CityName,
SalesPerson = sp.FullName

-- PostgreSQL
pc.CityName AS PostalCity,
sp.FullName AS SalesPerson
```
Apply this to every occurrence in the SELECT list.

### Data type casts inside the view body
| MSSQL | PostgreSQL |
|---|---|
| `CAST(x AS nvarchar(n))` | `CAST(x AS VARCHAR(n))` |
| `CAST(x AS nvarchar)` | `CAST(x AS TEXT)` |
| `CAST(x AS bit)` | `CAST(x AS BOOLEAN)` |
| `CAST(x AS datetime2)` | `CAST(x AS TIMESTAMP)` |
| `CONVERT(nvarchar, x)` | `x::TEXT` |
| `CONVERT(int, x)` | `x::INTEGER` |

### FOR JSON PATH (MSSQL-specific)
`FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` inside a subquery has no direct PostgreSQL equivalent.
Convert the subquery to a `json_build_object(...)` call:

```sql
-- MSSQL (simplified example)
JSON_QUERY((SELECT
    [type] = 'Feature',
    [geometry.type] = 'Point',
    [geometry.coordinates] = JSON_QUERY(CONCAT('[', c.DeliveryLocation.Long, ',', c.DeliveryLocation.Lat, ']'))
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))

-- PostgreSQL
json_build_object(
    'type', 'Feature',
    'geometry', json_build_object(
        'type', 'Point',
        'coordinates', json_build_array(ST_X(c.DeliveryLocation::geometry), ST_Y(c.DeliveryLocation::geometry))
    )
)
```

Rules for the translation:
- Each `[key] = value` pair inside the subquery becomes a `'key', value` argument to `json_build_object`.
- Dot-notation keys like `[geometry.type]` and `[geometry.coordinates]` represent nested objects — group them under a parent key (`geometry`) using a nested `json_build_object`.
- `[properties.Foo]` → nest under a `properties` key.
- `JSON_QUERY(CONCAT('[', x.Long, ',', x.Lat, ']'))` → `json_build_array(ST_X(x::geometry), ST_Y(x::geometry))`.
- Remove the outer `JSON_QUERY((...))` wrapper — `json_build_object` already returns `json`.
- Keep the column alias from the `Alias = JSON_QUERY(...)` pattern: `DeliveryLocation = JSON_QUERY(...)` → `json_build_object(...) AS DeliveryLocation`.

### Geography / spatial columns
- `col.Long` → `ST_X(col::geometry)`
- `col.Lat` → `ST_Y(col::geometry)`
- `col.STAsText()` → `ST_AsText(col)`
- Plain `col` references to a `geography` typed column — leave as-is; PostGIS geography columns work in SELECT.

### DECOMPRESS / compression functions
`DECOMPRESS(col)` has no PostgreSQL equivalent. Replace with a placeholder and add a TODO comment:
```sql
-- TODO: DECOMPRESS has no PostgreSQL equivalent; handle decompression in application layer
col AS FullSensorData
```

### JSON_VALUE / JSON_QUERY (used outside FOR JSON)
- `JSON_VALUE(col, '$.key')` → `col::jsonb ->> 'key'`
- `JSON_QUERY(col, '$.key')` → `(col::jsonb -> 'key')::text`

### ISNULL / COALESCE
- `ISNULL(a, b)` → `COALESCE(a, b)`

### String functions
- `LEN(x)` → `LENGTH(x)`
- `CHARINDEX(needle, haystack)` → `STRPOS(haystack, needle)`
- `SUBSTRING(x, start, len)` → `SUBSTRING(x FROM start FOR len)`
- `CONCAT(a, b, ...)` → `CONCAT(a, b, ...)` (unchanged — PostgreSQL supports it)

### Schema references in FROM / JOIN
- `[Application].People` → `application.people`
- `Sales.Customers` → `sales.customers` (already unbracketed; still lowercase the schema)
- Apply consistently to all `FROM`, `JOIN`, subquery `FROM` clauses.

### Schema creation
Prepend `CREATE SCHEMA IF NOT EXISTS <schema>;` at the top of every output file, where `<schema>` is the lowercase view schema.

## Step 3 — Determine output path

Mirror the source path under `postgres/`:
- Source: `wwi-ssdt/wwi-ssdt/WebApi/Views/Customers.sql`
- Output: `postgres/WebApi/Views/Customers.sql`

Create the directory if it does not exist.

## Step 4 — Dependency report

After writing each converted file, scan the output for every `schema.table` or `schema.view` reference in `FROM` and `JOIN` clauses. Build a deduplicated list.

For each referenced object:
1. Check for a converted table: `postgres/<Schema>/Tables/<Object>.sql`
2. Check for a converted view: `postgres/<Schema>/Views/<Object>.sql`
3. If neither exists → add to the "needs conversion" list.

End the response with a **"Next files to convert"** section:

```
Next files to convert (dependencies of what was just converted):

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql
       → required by: webapi.customers

  Run: /mssql-to-pgview wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql
       → required by: webapi.invoices

  Tip: Convert a whole schema at once:
       /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables
```

## Step 5 — Write conversion summary as a Markdown file

For each converted file, write a `.md` companion file alongside the `.sql` output.

- Source: `wwi-ssdt/wwi-ssdt/WebApi/Views/Customers.sql`
- SQL output: `postgres/WebApi/Views/Customers.sql`
- Summary output: `postgres/WebApi/Views/Customers.md`

The markdown file must contain:

```markdown
# Conversion summary: <OriginalFileName>.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/<Schema>/Views/<View>.sql`
- **Output:** `postgres/<Schema>/Views/<View>.sql`

## Conversions applied
- `[Schema].[View]` → `schema.view` (CREATE OR REPLACE VIEW)
- (one bullet per rule actually used, e.g. `Alias = expr` → `expr AS Alias`)
- (FOR JSON PATH → json_build_object if applicable)
- (geography .Long/.Lat → ST_X/ST_Y if applicable)
- (DECOMPRESS TODO if applicable)
- (data type casts if applicable)

## Unresolved dependencies

| Dependency | Referenced in | Run |
|---|---|---|
| `sales.customers` | FROM clause | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql` |

> Tip: `/mssql-to-pgview wwi-ssdt/wwi-ssdt/<Schema>/Views` converts the whole folder at once.
```

Only include bullets for conversions actually applied. Omit the dependency table if all referenced objects already have postgres output files.

If `geography` columns or `ST_X`/`ST_Y` were used, append:

```markdown
## PostGIS note
This view uses PostGIS spatial functions. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
```

If any `DECOMPRESS` TODOs were added, append:

```markdown
## TODOs
- `DECOMPRESS` has no PostgreSQL equivalent — decompression must be handled in the application layer.
```

## Step 6 — Print inline summary

After writing both files, print the same summary content inline in the conversation (do not make the user open the `.md` file). Then print the **"Next files to convert"** section.

If PostGIS was used, also print:
`"PostGIS extension required — run CREATE EXTENSION IF NOT EXISTS postgis; first."`

If DECOMPRESS TODOs were added, also print:
`"DECOMPRESS placeholder added — decompression must be handled in the application layer."`
