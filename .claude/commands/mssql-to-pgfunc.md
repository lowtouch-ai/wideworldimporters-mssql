---
description: Convert a MSSQL stored procedure to a PostgreSQL PL/pgSQL function, writing output to postgres/<Schema>/Functions/.
argument-hint: <stored-procedure-sql-file>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL Function Conversion

Given `$ARGUMENTS` (a single `.sql` file):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/`.
- If not, print an error and stop:
  ```
  Error: expected a stored procedure .sql file under wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/
  ```
- Extract `<Schema>` (e.g. `WebApi`) and `<SPName>` (e.g. `DeleteBuyingGroup`) from the path.

## Step 2 — Read and parse the SP

Read the `.sql` file. Extract:
- Schema name and procedure name (from `CREATE PROCEDURE [Schema].[Name]`)
- All parameters: name (`@name`), data type, TVP type name if any (`READONLY`)
- SP body for pattern classification
- All referenced tables, views, functions, sequences by scanning `FROM`, `JOIN`, `INSERT INTO`, `UPDATE`, `DELETE`, `NEXT VALUE FOR` clauses

## Step 3 — Check for Admin/DDL pattern

If the SP body contains dynamic SQL (`EXECUTE(@sql)`, `sp_executesql`, `ALTER`, `CREATE TABLE` outside of temp tables, `DROP TABLE` on permanent tables):
```
Skipping: this SP uses dynamic SQL/DDL and is not suitable for direct PL/pgSQL conversion.
```
Stop.

## Step 4 — Classify pattern (determines RETURNS type)

| Pattern | Detection heuristic | RETURNS |
|---|---|---|
| Simple DML | Only DELETE or UPDATE, no SELECT result set | `void` |
| Insert with OUTPUT | `OUTPUT inserted.X` clause | `TABLE(col type, ...)` with inserted columns |
| Insert from JSON | `OPENJSON` + `INSERT`, no result set SELECT | `void` |
| Update from JSON | `OPENJSON` + `UPDATE`, no result set SELECT | `void` |
| Search / Query | `SELECT` returning a result set (not assigned to var) | `TABLE(col type, ...)` |
| Complex / cursor / temporal | `CURSOR`, `FOR SYSTEM_TIME`, multiple result sets | `TABLE(col type, ...)` with TODOs |
| TVP-based transaction | TVP parameters + `BEGIN TRAN` | `void` or `TABLE(...)` |

For `TABLE(...)` return types: infer column names and types from the final `SELECT` list in the SP body. If the SELECT list is too complex (CTEs, dynamic, JSON wrapper), emit `TABLE(result jsonb)` and add a `-- TODO: refine return type` comment.

## Step 5 — Convert to PL/pgSQL

Apply all rules below to produce the function body.

### Structural

- `CREATE PROCEDURE [Schema].[Name]` → `CREATE OR REPLACE FUNCTION schema.snake_name`
- PascalCase procedure name → snake_case function name (e.g. `DeleteBuyingGroup` → `delete_buying_group`)
- Schema name → lowercase (e.g. `WebApi` → `webapi`)
- `WITH EXECUTE AS OWNER` → remove
- `AS BEGIN...END` → `AS $$ BEGIN...END; $$ LANGUAGE plpgsql;`
- `SET NOCOUNT ON` → remove
- `SET XACT_ABORT ON` → remove
- Add header comment: `-- Converted from: wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/<Name>.sql`

### Parameters

- `@name` → `p_name` (prefix avoids shadowing column names)
- `@name type` → `p_name type` in the function signature
- TVP parameters (`Schema.TypeName READONLY`) → `p_name jsonb`

### Data types

| MSSQL | PostgreSQL |
|---|---|
| `int` | `integer` |
| `nvarchar(n)` / `varchar(n)` | `varchar(n)` |
| `nvarchar(MAX)` / `nvarchar(max)` | `text` |
| `datetime2` / `datetime2(n)` | `timestamp` |
| `datetime` | `timestamp` |
| `date` | `date` |
| `bit` | `boolean` |
| `decimal(p,s)` / `numeric(p,s)` | `numeric(p,s)` |
| `bigint` | `bigint` |
| `smallint` | `smallint` |
| `float` | `double precision` |
| `uniqueidentifier` | `uuid` |
| `varbinary(MAX)` | `bytea` |
| `[sys].[geography]` | `geography` (PostGIS) |

### Variable declarations

- `DECLARE @var type;` → add `var type;` to the `DECLARE` block (before `BEGIN`)
- `DECLARE @var type = expr;` → `var type := expr;` in DECLARE block
- `SET @var = expr;` → `var := expr;`
- `SELECT @var = col FROM tbl WHERE ...` → `SELECT col INTO var FROM tbl WHERE ...`
- `SELECT @var = col` (no FROM) → `var := col;`

### Functions and expressions

| MSSQL | PostgreSQL |
|---|---|
| `ISNULL(x, y)` | `COALESCE(x, y)` |
| `SYSDATETIME()` | `CURRENT_TIMESTAMP` |
| `GETDATE()` | `CURRENT_TIMESTAMP` |
| `TOP(n)` in SELECT | `LIMIT n` (moved to end of query) |
| `TOP(@n)` | `LIMIT p_n` |
| `LIKE '%' + @x + '%'` | `LIKE '%' \|\| p_x \|\| '%'` |
| `NEXT VALUE FOR [Sequences].[FooID]` | `nextval('sequences.foo_id_seq')` |
| `@@ROWCOUNT` | `GET DIAGNOSTICS _rowcount = ROW_COUNT;` (declare `_rowcount integer` in DECLARE) |
| `NEWID()` | `gen_random_uuid()` (requires pgcrypto or pg 13+) |
| `PRINT N'msg'` | `RAISE NOTICE 'msg';` |
| `PRINT @var` | `RAISE NOTICE '%', var;` |
| `HASHBYTES(N'SHA2_256', @x)` | `digest(p_x, 'sha256')` (requires pgcrypto) |
| `CAST(x AS type)` | `CAST(x AS type)` (unchanged, adjust type per mapping above) |
| `CONVERT(type, x)` | `CAST(x AS type)` |
| `LEN(x)` | `LENGTH(x)` |
| `CHARINDEX(s, t)` | `POSITION(s IN t)` |
| `SUBSTRING(x, s, l)` | `SUBSTRING(x FROM s FOR l)` |
| `STUFF(x, s, l, r)` | `OVERLAY(x PLACING r FROM s FOR l)` |
| `COALESCE(x, y)` | `COALESCE(x, y)` (unchanged) |
| `NULLIF(x, y)` | `NULLIF(x, y)` (unchanged) |

### DML changes

- `OUTPUT inserted.X` → `RETURNING x` (snake_case column name if needed, else preserve)
- `OUTPUT inserted.X INTO @var` → `RETURNING x INTO var`
- `OPENJSON(@json) WITH (col nvarchar(50) '$.field')` →
  Use `json_populate_recordset` with a declared type, or inline with `jsonb_to_recordset`:
  ```sql
  SELECT col FROM jsonb_to_recordset(p_json::jsonb) AS x(col varchar(50))
  ```
  For INSERT from JSON:
  ```sql
  INSERT INTO schema.table (col, last_edited_by)
  SELECT col, p_user_id
  FROM jsonb_to_recordset(p_json::jsonb) AS x(col varchar(50));
  ```
- `FOR JSON PATH` → `json_agg(row_to_json(t))` — flag with `-- TODO: verify JSON shape matches original`
- `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` → `row_to_json(t)` for single row, else add TODO
- `SELECT TOP(@n) ... FOR JSON PATH` → use subquery with LIMIT, then `json_agg(...)` — add TODO

### Temp tables

- `CREATE TABLE #Foo (col type, ...)` → `CREATE TEMP TABLE foo (col type, ...);`
- `DROP TABLE #Foo` → `DROP TABLE IF EXISTS foo;`
- Temp table names: remove `#`, lowercase
- Index on temp table: `CREATE INDEX ix_foo_col ON foo (col);`
- `INSERT #Foo` → `INSERT INTO foo`
- `UPDATE cc ... FROM #Foo` → `UPDATE foo ...`

### Cursors

Simple single-column cursor (FETCH one column per row, linear loop):
```sql
-- MSSQL
DECLARE cur CURSOR FOR SELECT col FROM tbl;
OPEN cur;
FETCH NEXT FROM cur INTO @val;
WHILE @@FETCH_STATUS = 0 BEGIN
  -- body
  FETCH NEXT FROM cur INTO @val;
END;
CLOSE cur; DEALLOCATE cur;

-- PostgreSQL
FOR rec IN SELECT col FROM tbl LOOP
  -- body (use rec.col)
END LOOP;
```

Multi-column cursors: convert to `FOR rec IN (query) LOOP` using `rec.colname`. If cursor logic is too complex (FAST_FORWARD, UNION, ORDER BY with multiple FETCH columns), add `-- TODO: refactor cursor` and keep structure as a FOR loop with a comment.

### Temporal tables (FOR SYSTEM_TIME)

No PostgreSQL equivalent without extensions. Convert to a regular join and emit:
```sql
-- TODO: FOR SYSTEM_TIME AS OF p_valid_from not supported natively in PostgreSQL.
-- Rewrite using audit/history table with a date-range WHERE clause.
INNER JOIN schema.table AS t  -- was: FOR SYSTEM_TIME AS OF @ValidFrom
```

### Error handling

```sql
-- MSSQL
BEGIN TRY
  BEGIN TRAN;
  ...
  COMMIT;
END TRY
BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  PRINT N'Error occurred.';
  THROW;
  RETURN -1;
END CATCH;

-- PostgreSQL
BEGIN
  ...
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error occurred.';
  RAISE;
END;
```

- `IF XACT_STATE() <> 0 ROLLBACK` → remove (PostgreSQL automatically rolls back on exception inside a function)
- `RETURN 0` / `RETURN -1` in void functions → remove
- In TABLE-returning functions: `RETURN QUERY SELECT ...`
- In scalar functions: `RETURN var;`

### Sequence references

`NEXT VALUE FOR [Sequences].[FooID]` → `nextval('sequences.foo_id_seq')`
- Strip brackets, lowercase both parts
- `FooID` → `foo_id` → `sequences.foo_id_seq`

### Square brackets and schema references

- Strip all `[square brackets]` from identifiers
- `[Schema].[Table]` → `schema.table` (both lowercase)
- Column names: preserve original casing (e.g. `"OrderID"`, `"CustomerPurchaseOrderNumber"`)
- Quoted column names in SQL strings: use double-quotes `"ColumnName"`

## Step 6 — Write output file

Output path: `postgres/<Schema>/Functions/<snake_case_name>.sql`

File structure:
```sql
-- Converted from: wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/<Name>.sql
CREATE SCHEMA IF NOT EXISTS <schema_lower>;

CREATE OR REPLACE FUNCTION <schema_lower>.<snake_name>(
    p_param1 type1,
    p_param2 type2
) RETURNS <return_type> AS $$
DECLARE
    -- local variable declarations
BEGIN
    -- converted body
END;
$$ LANGUAGE plpgsql;
```

Create the `postgres/<Schema>/Functions/` directory by writing the file (Write tool creates missing directories).

## Step 7 — Write companion markdown

Write `postgres/<Schema>/Functions/<snake_case_name>.md`:

```markdown
# Conversion summary: <Schema>.<SPName>

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/<Name>.sql`
- **Pattern:** <classified pattern from Step 4>
- **Output:** `postgres/<Schema>/Functions/<snake_name>.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION <schema>.<snake_name>(<params>) RETURNS <type>
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Param int` | `p_param integer` | integer | |
| `@Json nvarchar(MAX)` | `p_json text` | text | Payload JSON |

## Conversion notes
- (one bullet per conversion actually applied, e.g. `OPENJSON → jsonb_to_recordset`)
- (cursor conversion note if applicable)
- (temporal table TODO if applicable)
- (sequence reference conversions)

## TODOs
- (list each `-- TODO:` comment emitted in the output)

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
```

## Step 8 — Print inline summary

Print to the conversation:
- Source SP, classified pattern
- Output file path and function signature
- TODOs count and list
- Tables referenced

Then check for other unconverted SPs in the same schema folder. If there are more `.sql` files in the same `Stored Procedures/` directory without a corresponding `postgres/<Schema>/Functions/` output, list them:

```
Other stored procedures in <Schema> not yet converted to PL/pgSQL:

  /mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/InsertFoo.sql"
  /mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/<Schema>/Stored Procedures/UpdateBar.sql"
```

## Important notes

- **Never auto-commit generated files.** Leave output uncommitted for user review.
- Preserve original column name casing in SQL strings; double-quote all column names.
- Flag anything that requires manual review with `-- TODO:` comments.
- For `FOR SYSTEM_TIME AS OF` patterns, always emit the TODO comment — do not silently drop the temporal logic.
- If PostGIS `geography` type is used, note at the end: `-- Requires: CREATE EXTENSION IF NOT EXISTS postgis;`
