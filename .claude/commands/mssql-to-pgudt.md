---
description: Convert a MSSQL TABLE TYPE (User Defined Type) to a PostgreSQL composite CREATE TYPE, writing output to postgres/<Schema>/Types/.
argument-hint: <udt-sql-file>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL User Defined Type Conversion

Given `$ARGUMENTS` (a single `.sql` file):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/`.
- If not, print an error and stop:
  ```
  Error: expected a UDT .sql file under wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/
  ```
- Extract `<Schema>` (e.g. `Website`) and `<TypeName>` (e.g. `OrderIDList`) from the path.

## Step 2 — Read and parse the UDT file

Read the `.sql` file. Extract:
- Schema name and type name (from `CREATE TYPE [Schema].[TypeName] AS TABLE`)
- All columns: name, data type, nullability, IDENTITY flag, PRIMARY KEY flag
- INDEX definitions (column name(s) indexed)
- Whether `MEMORY_OPTIMIZED = ON` is present

If the file does not contain `CREATE TYPE ... AS TABLE`, stop with:
```
Error: this file does not define a TABLE TYPE. Only TABLE TYPE UDTs are supported by /mssql-to-pgudt.
```

## Step 3 — Derive output names

- Schema name → **lowercase** (e.g. `Website` → `website`)
- Type name → **lowercase snake_case** (e.g. `OrderIDList` → `order_id_list`, `SensorDataList` → `sensor_data_list`)
- Column names → **preserve original casing** (e.g. `OrderID`, `StockItemID`)

## Step 4 — Apply conversion rules

### Strip MSSQL-only clauses
Remove these clauses entirely — they have no PostgreSQL equivalent:
- `WITH (MEMORY_OPTIMIZED = ON)` — PostgreSQL does not have in-memory table types
- `PRIMARY KEY NONCLUSTERED (...)` — composite types have no constraints
- `INDEX [name] (col ASC)` / `INDEX [name] (col)` — composite types have no indexes
- `IDENTITY (1, 1)` — composite types have no identity; document in `.md` that callers must supply or sequence-generate this value

### Type declaration
```sql
-- MSSQL
CREATE TYPE [Website].[OrderList] AS TABLE (
    [OrderReference] INT NOT NULL,
    [CustomerID]     INT NULL,
    ...
    PRIMARY KEY NONCLUSTERED ([OrderReference] ASC))
WITH (MEMORY_OPTIMIZED = ON);

-- PostgreSQL
CREATE SCHEMA IF NOT EXISTS website;
CREATE TYPE website.order_list AS (
    OrderReference integer,
    CustomerID     integer,
    ...
);
```

Composite types have no NOT NULL, no PRIMARY KEY, no constraints — all columns become plain `name type` pairs.

### Data type mapping
| MSSQL | PostgreSQL |
|---|---|
| `INT` | `integer` |
| `BIGINT` | `bigint` |
| `SMALLINT` | `smallint` |
| `NVARCHAR(n)` | `varchar(n)` |
| `NVARCHAR(MAX)` | `text` |
| `VARCHAR(n)` | `varchar(n)` |
| `DATETIME2(7)` | `timestamp(6)` |
| `DATETIME2(n)` | `timestamp(n)` |
| `DATE` | `date` |
| `BIT` | `boolean` |
| `DECIMAL(p,s)` | `numeric(p,s)` |
| `NUMERIC(p,s)` | `numeric(p,s)` |
| `FLOAT` | `double precision` |
| `UNIQUEIDENTIFIER` | `uuid` |
| `VARBINARY(MAX)` | `bytea` |

### Single-column integer types
When the UDT has exactly one column of type `integer` (e.g. `OrderIDList` with just `OrderID int`), the composite type is still emitted, but add a prominent note in the companion `.md` that `integer[]` is the idiomatic PostgreSQL shorthand:

```
-- NOTE: single-column integer type — callers may prefer integer[] instead of website.order_id_list[]
```

### Output file structure
```sql
-- Converted from: wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/<TypeName>.sql
CREATE SCHEMA IF NOT EXISTS <schema_lower>;

CREATE TYPE <schema_lower>.<type_snake> AS (
    ColumnName1 pgtype1,
    ColumnName2 pgtype2,
    ...
);
```

No `IF NOT EXISTS` for `CREATE TYPE` — PostgreSQL does not support it (use `DROP TYPE IF EXISTS` before re-running if needed). Add a comment:
```sql
-- Re-run: DROP TYPE IF EXISTS <schema_lower>.<type_snake>; before applying if type already exists.
```

## Step 5 — Determine output path

Mirror the source path under `postgres/`, using a `Types/` directory:
- Source: `wwi-ssdt/wwi-ssdt/Website/User Defined Types/OrderIDList.sql`
- Output: `postgres/Website/Types/order_id_list.sql`

Create the directory if it does not exist (Write tool creates missing directories).

## Step 6 — Write companion markdown

Write `postgres/<Schema>/Types/<type_snake>.md`:

```markdown
# Conversion summary: <Schema>.<TypeName>

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/<TypeName>.sql`
- **Output:** `postgres/<Schema>/Types/<type_snake>.sql`

## Type mapping
- **MSSQL:** `CREATE TYPE [<Schema>].[<TypeName>] AS TABLE` (memory-optimized)
- **PostgreSQL:** `CREATE TYPE <schema>.<type_snake> AS` (composite type)

## Conversions applied
- `MEMORY_OPTIMIZED = ON` → removed (no PostgreSQL equivalent)
- `PRIMARY KEY NONCLUSTERED` → removed (composite types have no constraints)
- (INDEX bullet if indexes were stripped)
- (IDENTITY bullet if IDENTITY column was present)
- (one bullet per data type mapping actually used)

## Calling convention change

**MSSQL (TVP):**
```sql
-- Declare a table variable of this type and pass it to a stored procedure
DECLARE @orders Website.OrderList;
INSERT INTO @orders VALUES (1, 42, ...);
EXEC Website.InsertOrdersLines @Orders = @orders, @SalespersonID = 1;
```

**PostgreSQL (composite type array):**
```sql
-- Pass an array of the composite type to a PL/pgSQL function
SELECT website.insert_order_lines(
    p_orders  := ARRAY[ROW(1, 42, ...)::website.order_list, ...],
    p_salesperson_id := 1
);
```

**PostgreSQL (jsonb — used by mssql-to-pgfunc default):**
```sql
-- The mssql-to-pgfunc skill converts TVP parameters to jsonb by default
SELECT website.insert_order_lines(
    p_orders  := '[{"OrderReference":1,"CustomerID":42,...}]'::jsonb,
    p_salesperson_id := 1
);
```

> The `mssql-to-pgfunc` skill rewrites TVP parameters to `jsonb` in converted functions. The composite type defined here serves as the formal schema anchor and documents the column contract. Use `website.<type_snake>[]` arrays in functions where strict typing is preferred over `jsonb`.

## TODOs
(list any removed constraints, IDENTITY columns, or indexes that need manual attention)

## Single-column note (if applicable)
`<TypeName>` has a single `integer` column. PostgreSQL callers may prefer `integer[]` directly instead of `website.<type_snake>[]`. Both are valid; choose based on whether strict typing or brevity matters more.
```

## Step 7 — Print inline summary

Print to the conversation:
```
Converted: wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/<TypeName>.sql
       → postgres/<Schema>/Types/<type_snake>.sql

Type:    <schema>.<type_snake> AS (<col1> type1, <col2> type2, ...)
Columns: <n>

Stripped (MSSQL-only):
  • MEMORY_OPTIMIZED = ON
  • PRIMARY KEY NONCLUSTERED
  (• IDENTITY (1, 1) on <ColName> — callers must supply this value or use a sequence)
  (• INDEX [name] on (<col>))

Calling convention:
  • mssql-to-pgfunc default → jsonb parameter (compatible with this type)
  • Strict typing → <schema>.<type_snake>[] array parameter
  (• Single-column shorthand → integer[] preferred)
```

Then check for other unconverted UDTs in the same `User Defined Types/` directory. If there are more `.sql` files without a corresponding `postgres/<Schema>/Types/` output, list them:

```
Other UDTs in <Schema> not yet converted:

  /mssql-to-pgudt "wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/OrderLineList.sql"
  /mssql-to-pgudt "wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/SensorDataList.sql"
```

## Important notes

- **Never auto-commit generated files.** Leave output uncommitted for user review.
- Composite types cannot use `IF NOT EXISTS`. The output file includes a `DROP TYPE IF EXISTS` comment for safe re-runs.
- Column names are preserved in their original casing. In PostgreSQL, composite type column names are case-insensitive unless double-quoted, so document this in the `.md` if casing is significant.
- The `mssql-to-pgfunc` skill already converts TVP parameters to `jsonb` — this skill produces the formal composite type that serves as the schema contract, not a replacement for the `jsonb` pattern.
