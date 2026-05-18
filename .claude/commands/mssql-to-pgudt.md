---
description: Convert a MSSQL User Defined Type (TVP) to a PostgreSQL composite type, writing output to postgres/<Schema>/Types/.
argument-hint: <udt-sql-file-or-folder>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL UDT Conversion

Given `$ARGUMENTS` (a `.sql` file or a directory):

## Step 1 — Collect files to convert

- If `$ARGUMENTS` is a `.sql` file → convert that one file.
- If `$ARGUMENTS` is a directory → glob `**/*.sql` inside it and convert every file found.
- If a file does not contain `CREATE TYPE ... AS TABLE`, skip it and print a warning.

## Step 2 — Parse and validate

Extract from `CREATE TYPE [Schema].[TypeName] AS TABLE (...)`:
- Schema name (e.g. `Website`)
- Type name (e.g. `OrderIDList`)
- Column list (everything inside the outer parentheses, before any trailing `WITH (...)`)

If the file contains `CREATE TYPE ... FROM` (a scalar domain type) rather than `AS TABLE`, skip it and print: `"Skipped <file>: scalar domain types are not yet supported by this skill."`

## Step 3 — Apply conversion rules

### Type name and schema
- Strip all square-bracket quoting: `[Website].[OrderIDList]` → `website.order_id_list`
- Schema: **lowercase**
- Type name: **snake_case** (e.g. `OrderIDList` → `order_id_list`, `SensorDataList` → `sensor_data_list`)
- Statement: `CREATE TYPE [Schema].[Name] AS TABLE (...)` → `CREATE TYPE schema.name AS (...)`

### Column list — strip MSSQL-only clauses

Remove these from the column list entirely (do not emit them):
- `PRIMARY KEY NONCLUSTERED (...)` — entire clause including surrounding parentheses
- `INDEX [name] (cols)` — entire clause
- `WITH (MEMORY_OPTIMIZED = ON)` — trailing table option
- `IDENTITY (seed, increment)` — from individual column definitions
- `NOT NULL` and `NULL` — composite type fields have no nullability constraint
- `ASC` / `DESC` inside removed key clauses

After stripping, trailing commas left by removed lines must be cleaned up.

### Data type mappings

| MSSQL | PostgreSQL |
|---|---|
| `INT` | `integer` |
| `NVARCHAR(n)` | `varchar(n)` |
| `NVARCHAR(MAX)` | `text` |
| `BIT` | `boolean` |
| `DATE` | `date` |
| `DATETIME2(n)` | `timestamp(n)` |
| `DECIMAL(p,s)` | `numeric(p,s)` |
| `FLOAT` | `double precision` |
| `BIGINT` | `bigint` |
| `SMALLINT` | `smallint` |
| `TINYINT` | `smallint` |
| `UNIQUEIDENTIFIER` | `uuid` |
| `VARBINARY(MAX)` | `bytea` |

### Usage comment

Prepend a two-line comment immediately above `CREATE TYPE`:
```sql
-- PostgreSQL composite type for <Schema>.<OriginalTypeName> TVP.
-- Use as an array parameter in functions: p_name schema.type_name[]
```

### Schema creation

Prepend `CREATE SCHEMA IF NOT EXISTS <schema>;` at the very top of the output file.

### Column name casing

**Preserve original column name casing** exactly as in the source (e.g. `OrderID`, `ColdRoomSensorNumber`).

## Step 4 — Determine output path

Mirror the source path under `postgres/`, placing types in a `Types/` subfolder:

- Source: `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql`
- Output: `postgres/Website/Types/OrderIDList.sql`

Create the output directory if it does not exist.

## Step 5 — Dependency report

After converting each type, grep the following locations for references to the original type name (e.g. `Website.OrderIDList` or `[Website].[OrderIDList]`):
- `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/`
- `wwi-ssdt/wwi-ssdt/` (all other schemas)

For each referencing stored procedure file found:
1. Derive its expected converted output path: `postgres/<Schema>/Functions/<snake_case_name>.sql`
2. Check whether that converted file exists.

Report as a table:

```
Functions that use this type:
  Website.InsertCustomerOrders → postgres/Website/Functions/insert_customer_orders.sql  ✗ not yet converted
  Website.SearchForPeople      → postgres/Website/Functions/search_for_people.sql       ✓ converted
```

## Step 6 — Write conversion summary as a Markdown file

For each converted file, write a `.md` companion alongside the `.sql` output.

- SQL output:  `postgres/Website/Types/OrderIDList.sql`
- Summary:     `postgres/Website/Types/OrderIDList.md`

```markdown
# Conversion summary: OrderIDList.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql`
- **Output:** `postgres/Website/Types/OrderIDList.sql`

## Conversions applied
- `[Website].[OrderIDList]` → `website.order_id_list` (composite type)
- Column nullability (`NOT NULL` / `NULL`) → stripped (not enforced in composite types)
- `PRIMARY KEY NONCLUSTERED` → removed
- `WITH (MEMORY_OPTIMIZED = ON)` → removed
- (list any `IDENTITY` removal, data type casts, etc. that were actually applied)

## Usage in functions
Pass as a typed array parameter:
```sql
p_order_id_list website.order_id_list[]
```
Then unnest inside the function body:
```sql
SELECT * FROM unnest(p_order_id_list) AS t(OrderID)
```

## Functions that reference this type
| Stored Procedure | Converted? |
|---|---|
| `Website.InsertCustomerOrders` | ✗ not yet converted |
```

Only include bullets for conversions actually applied. Omit the functions table if no referencing SPs were found.

## Step 7 — Print inline summary

After writing both files, print the same summary content inline in the conversation. Include:
- The output file path
- Conversions applied (bullet list)
- The usage snippet
- The functions dependency table

End with:
```
Next: convert referencing stored procedures with /mssql-to-pgfunc
  e.g. /mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InsertCustomerOrders.sql"
```

If there are no unconverted referencing SPs, omit the "Next" block.
