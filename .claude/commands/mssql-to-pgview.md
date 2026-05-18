---
description: Convert a MSSQL CREATE VIEW file (or all .sql files in a Views folder) to PostgreSQL CREATE OR REPLACE VIEW and report which referenced tables still need conversion.
argument-hint: <file-or-folder-path>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL View Conversion

Given `$ARGUMENTS` (a `.sql` file or a directory):

## Step 1 — Collect files to convert

- If `$ARGUMENTS` is a `.sql` file under `wwi-ssdt/wwi-ssdt/<Schema>/Views/` → convert that one file.
- If `$ARGUMENTS` is a directory → glob `**/*.sql` inside it and convert every file found.
- If the path does not match `wwi-ssdt/wwi-ssdt/<Schema>/Views/`, print an error and stop:
  ```
  Error: expected a view .sql file or folder under wwi-ssdt/wwi-ssdt/<Schema>/Views/
  ```

## Step 2 — For each file, apply these conversion rules

### Quoting / identifiers
- Strip all `[square bracket]` quoting from identifiers.
- Schema names → **lowercase** (e.g. `[WebApi]` → `webapi`).
- View names → **lowercase snake_case** (e.g. `[SalesOrders]` → `sales_orders`).
- **Preserve original casing for column names** in the SELECT list (e.g. `CustomerID`, `FullName`).

### View declaration
- `CREATE VIEW [Schema].[ViewName]` → emit `CREATE SCHEMA IF NOT EXISTS schema;` first, then `CREATE OR REPLACE VIEW schema.view_snake_name AS`
- `WITH SCHEMABINDING` → remove (not needed in PostgreSQL)
- `WITH VIEW_METADATA` → remove

### Column aliases
MSSQL allows the reversed alias form `Alias = expr`. Convert to standard SQL form:
- `ColAlias = expr` → `expr AS ColAlias`
- `expr AS ColAlias` → unchanged

### JOIN syntax
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `RIGHT OUTER JOIN` → `RIGHT JOIN`
- `FULL OUTER JOIN` → `FULL JOIN`
- `INNER JOIN` → `JOIN` (or keep `INNER JOIN` — both valid)

### Schema-qualified references
- `[Schema].[Table]` → `schema.table` (both lowercase) in FROM, JOIN, and subquery clauses
- `[Schema].[View]` → `schema.view_snake_name` when referencing another view

### Data type casts
| MSSQL | PostgreSQL |
|---|---|
| `CAST(x AS NVARCHAR(n))` | `CAST(x AS VARCHAR(n))` |
| `CAST(x AS NVARCHAR(MAX))` | `CAST(x AS TEXT)` |
| `CAST(x AS BIT)` | `CAST(x AS BOOLEAN)` |
| `CAST(x AS DATETIME2)` | `CAST(x AS TIMESTAMP)` |
| `CONVERT(type, expr)` | `CAST(expr AS type)` (adjust type per above) |

### Functions
| MSSQL | PostgreSQL |
|---|---|
| `ISNULL(x, y)` | `COALESCE(x, y)` |
| `GETDATE()` | `CURRENT_TIMESTAMP` |
| `SYSDATETIME()` | `CURRENT_TIMESTAMP` |
| `LEN(x)` | `LENGTH(x)` |
| `CHARINDEX(s, t)` | `POSITION(s IN t)` |
| `SUBSTRING(x, s, l)` | `SUBSTRING(x FROM s FOR l)` |
| `CONCAT(a, b, ...)` | `CONCAT(a, b, ...)` (unchanged) |
| `COALESCE(x, y)` | `COALESCE(x, y)` (unchanged) |
| `NULLIF(x, y)` | `NULLIF(x, y)` (unchanged) |
| `TOP(n)` | `LIMIT n` (append to end of query) |

### Geography property extraction
MSSQL geography objects expose `.Lat` and `.Long` as property accessors. Map to PostGIS:
- `col.Long` → `ST_X(col::geometry)`
- `col.Lat` → `ST_Y(col::geometry)`
- `col.STAsText()` → `ST_AsText(col)`
- `col.STDistance(other)` → `ST_Distance(col::geometry, other::geometry)`

Add a PostGIS note in the companion `.md` if any geography conversions were applied.

### JSON transformations
`JSON_QUERY(... FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)` — these are complex MSSQL-specific JSON serialisation expressions. Convert as follows:

**Simple case** — a subquery that selects columns and wraps them in JSON:
```sql
-- MSSQL
JSON_QUERY((SELECT col1 = t.Col1, col2 = t.Col2 FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))

-- PostgreSQL
(SELECT row_to_json(t) FROM (SELECT t.Col1 AS col1, t.Col2 AS col2) t)
```

**Array case** — `FOR JSON PATH` without `WITHOUT_ARRAY_WRAPPER`:
```sql
-- MSSQL
(SELECT col FROM tbl FOR JSON PATH)

-- PostgreSQL
(SELECT json_agg(row_to_json(r)) FROM (SELECT col FROM tbl) r)
```

**Complex case** — nested keys using dot notation (e.g. `[geometry.coordinates]`, `[properties.City]`):
Emit a `-- TODO: verify JSON shape matches original FOR JSON PATH output` comment and do a best-effort conversion using `json_build_object`:
```sql
-- PostgreSQL (best-effort)
json_build_object(
    'type', 'Feature',
    'geometry', json_build_object('type', 'Point', 'coordinates', ARRAY[ST_X(col::geometry), ST_Y(col::geometry)]),
    'properties', json_build_object('City', city_col)
)
-- TODO: verify JSON shape matches original FOR JSON PATH output
```

Always flag `FOR JSON PATH` conversions with a TODO comment.

### String concatenation
- `col1 + col2` (string concatenation in MSSQL) → `col1 || col2`
- Only applies when both sides are character types; numeric `+` is unchanged.

### Schema creation header
Prepend `CREATE SCHEMA IF NOT EXISTS schema;` at the top of every output file.

## Step 3 — Determine output path

Mirror the source path under `postgres/`, using the snake_case view name:
- Source: `wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql`
- Output: `postgres/WebApi/Views/sales_orders.sql`

Create the directory if it does not exist (Write tool creates missing directories).

## Step 4 — Check table dependencies

After writing each converted file, scan the output for all `schema.table` references in FROM and JOIN clauses. Build a deduplicated list of referenced schema/table pairs.

For each referenced pair:
1. Compute its expected postgres path: `postgres/<Schema>/Tables/<Table>.sql`
2. If the postgres path does **not** exist → add to "needs conversion" list, noting which view(s) depend on it.
3. Also check for referenced views: `postgres/<Schema>/Views/<view_snake>.sql` — note if missing.

End the response with a **"Next files to convert"** section:

```
Next files to convert (table dependencies of converted views):

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql
       → required by: webapi.customers, website.customers

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
       → required by: webapi.customers (PrimaryContact, AlternateContact)

  Tip: Convert all tables in a schema at once:
       /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables
```

## Step 5 — Write conversion summary as a Markdown file

For each converted file, write a `.md` companion alongside the output `.sql`:
- Source: `wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql`
- SQL output: `postgres/WebApi/Views/sales_orders.sql`
- Summary output: `postgres/WebApi/Views/sales_orders.md`

```markdown
# Conversion summary: <Schema>.<ViewName>

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/<Schema>/Views/<View>.sql`
- **Output:** `postgres/<Schema>/Views/<view_snake>.sql`

## Conversions applied
- `[Schema].[ViewName]` → `schema.view_snake_name`
- (one bullet per rule actually applied, e.g. `ISNULL → COALESCE`, `LEFT OUTER JOIN → LEFT JOIN`)
- (column alias bullet if `Alias = expr` form was reversed)
- (geography bullet if `.Lat`/`.Long` were converted)
- (JSON TODO bullet if FOR JSON PATH was present)
- (string concat bullet if `+` → `||`)

## TODOs
- (list each `-- TODO:` comment emitted in the output, if any)

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✗ missing |
| `application.people` | `postgres/Application/Tables/People.sql` | ✗ missing |

> Tip: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql`
```

Only include bullets for conversions actually performed. Omit the dependency table if all referenced tables already have postgres output files.

If geography columns were converted, append:

```markdown
## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
```

## Step 6 — Print inline summary

After writing both files, print the same summary to the conversation (do not make the user open the `.md` file). Then print the **"Next files to convert"** section.

```
Converted: wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql
       → postgres/WebApi/Views/sales_orders.sql

Conversions applied:
  • [WebApi].[SalesOrders] → webapi.sales_orders
  • LEFT OUTER JOIN → LEFT JOIN (3 occurrences)
  • ISNULL → COALESCE (1 occurrence)
  • Column alias `Alias = expr` → `expr AS Alias` (2 columns)

TODOs: 1
  • FOR JSON PATH conversion — verify JSON shape matches original

Next files to convert (table dependencies):

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql
       → required by: webapi.sales_orders

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Invoices.sql
       → required by: webapi.sales_orders
```

If converting a whole folder, print a consolidated report across all files at the end.

## Important notes

- **Never auto-commit generated files.** Leave output uncommitted for user review.
- Preserve original column name casing in the SELECT list; use double-quotes for column aliases only when the name contains special characters or is a reserved word.
- `FOR JSON PATH` conversions are always flagged with `-- TODO:` — do not silently drop or rewrite complex JSON expressions without a TODO marker.
- If a view references another view (not just tables), note the dependency but do not block conversion.
- Other unconverted views in the same `Views/` directory:

```
Other views in <Schema> not yet converted:

  /mssql-to-pgview "wwi-ssdt/wwi-ssdt/<Schema>/Views/OtherView.sql"
```
