---
description: Convert a MSSQL DDL file (or all .sql files in a folder) to PostgreSQL and report which referenced files still need conversion.
argument-hint: <file-or-folder-path>
allowed-tools: [Read, Glob, Grep, Write, Edit]
---

# MSSQL → PostgreSQL Conversion

Given `$ARGUMENTS` (a `.sql` file or a directory):

## Step 1 — Collect files to convert

- If `$ARGUMENTS` is a `.sql` file → convert that one file.
- If `$ARGUMENTS` is a directory → glob `**/*.sql` inside it and convert every file found.

## Step 2 — For each file, apply these conversion rules

### Quoting / identifiers
- Strip square-bracket quoting: `[SalesOrders]` → `sales_orders` — **keep original
  casing for column names**; lowercase schema and table names.
- Remove `GO` statement separators; PostgreSQL uses `;`.

### Data types
| MSSQL | PostgreSQL |
|---|---|
| `INT` | `INTEGER` |
| `NVARCHAR(n)` | `VARCHAR(n)` |
| `NVARCHAR(MAX)` | `TEXT` |
| `DATETIME2(7)` | `TIMESTAMP(6)` |
| `DATETIME2(n)` | `TIMESTAMP(n)` |
| `BIT` | `BOOLEAN` |
| `DECIMAL(p,s)` | `NUMERIC(p,s)` |
| `VARBINARY(MAX)` | `BYTEA` |
| `[sys].[geography]` | `geography` (PostGIS) |
| `DATE` | `DATE` (unchanged) |

### Default values & sequences
- `DEFAULT (NEXT VALUE FOR [Sequences].[FooID])` →
  `DEFAULT nextval('sequences.foo_id_seq')` (snake_case the sequence name)
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Remove named-default constraint syntax:
  `CONSTRAINT [DF_...] DEFAULT (...)` → `DEFAULT (...)`

### Sequence objects (emit before the table if a sequence is consumed)
```sql
CREATE SEQUENCE IF NOT EXISTS sequences.foo_id_seq START 1 INCREMENT 1;
```

### Temporal tables (SYSTEM_VERSIONING)
Tables that have `PERIOD FOR SYSTEM_TIME` and `WITH (SYSTEM_VERSIONING = ON ...)`:
- Drop the `PERIOD FOR SYSTEM_TIME (...)` clause.
- Drop the `WITH (SYSTEM_VERSIONING = ON ...)` clause.
- Convert `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` columns
  to plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`.
- The `_Archive` companion table (already a plain table) converts normally.

### Constraint naming
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- `CONSTRAINT [name] FOREIGN KEY ...` → keep `CONSTRAINT name FOREIGN KEY ...`
  (remove brackets from name).
- `CHECK` constraints: rewrite MSSQL `CASE` expressions to standard SQL; PostgreSQL
  supports standard `CASE` so usually the body is the same — just remove brackets.

### Indexes
- `CREATE NONCLUSTERED INDEX [name] ON [schema].[table]([col] ASC)` →
  `CREATE INDEX name ON schema.table (col ASC);`
- `INCLUDE (...)` clause — keep as-is (PostgreSQL ≥ 11 supports it).
- `CREATE COLUMNSTORE INDEX ...` → **omit** (no equivalent; add a comment
  `-- COLUMNSTORE index omitted: no PostgreSQL equivalent`).

### Extended properties
`EXECUTE sp_addextendedproperty ... @level1name = N'Table', @level2type = N'COLUMN', @level2name = N'Col'`
→
```sql
COMMENT ON COLUMN schema.table.col IS 'description text';
```
`@level2type` absent (table-level) →
```sql
COMMENT ON TABLE schema.table IS 'description text';
```
`@level2type = 'INDEX'` → omit (PostgreSQL does not support index comments via standard DDL).

### Schema creation
Prepend `CREATE SCHEMA IF NOT EXISTS <schema>;` at the top of every output file.

## Step 3 — Determine output path

Mirror the source path under `postgres/`:
- Source: `wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql`
- Output: `postgres/Sales/Tables/Orders.sql`

Create the directory if it does not exist (use `Write` to create the file).

## Step 4 — Suggest remaining files to convert (dependency report)

After writing each converted file, grep the output for every `REFERENCES schema.table`
clause.  Build a deduplicated list of all referenced schema/table pairs.

For each referenced pair:
1. Compute its MSSQL source path: `wwi-ssdt/wwi-ssdt/<Schema>/Tables/<Table>.sql`
2. Compute its expected postgres path: `postgres/<Schema>/Tables/<Table>.sql`
3. If the postgres path does **not** exist yet → add to the "needs conversion" list,
   noting which converted table(s) depend on it.

End the response with a clear **"Next files to convert"** section:

```
Next files to convert (dependencies of what was just converted):

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
       → required by: Sales.Customers, Sales.Orders, Sales.Invoices

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql
       → required by: Sales.Customers

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems.sql
       → required by: Sales.InvoiceLines, Sales.OrderLines

  Tip: Convert a whole schema at once:
       /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables
```

This makes it easy to chain conversions until all dependencies are satisfied.

## Step 5 — Write conversion summary as a Markdown file

For each converted file, write a `.md` file alongside the output `.sql` file with the same base name.

- Source: `wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql`
- SQL output: `postgres/Sales/Tables/Orders.sql`
- Summary output: `postgres/Sales/Tables/Orders.md`

The markdown file must contain:

```markdown
# Conversion summary: <OriginalFileName>.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/<Schema>/Tables/<Table>.sql`
- **Output:** `postgres/<Schema>/Tables/<Table>.sql`

## Conversions applied
- `[Schema].[Table]` → `schema.table`
- (one bullet per data type mapping that was actually used, e.g. `INT → INTEGER`, `NVARCHAR(MAX) → TEXT`)
- (sequence bullet if applicable, e.g. `NEXT VALUE FOR [Sequences].[FooID]` → `nextval('sequences.foo_id_seq')` + `CREATE SEQUENCE` emitted)
- (DEFAULT sysdatetime bullet if applicable)
- (named-default constraint removal bullet if applicable)
- (PRIMARY KEY CLUSTERED → PRIMARY KEY if applicable)
- (UNIQUE NONCLUSTERED → UNIQUE if applicable)
- (CREATE NONCLUSTERED INDEX → CREATE INDEX if applicable)
- (temporal table handling bullet if applicable)
- (COLUMNSTORE omission bullet if applicable)
- (counts of index-level / table-level / column-level extended properties, e.g. `4 index-level extended properties → omitted (with comment)`)

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `sales.orders (LastEditedBy, ContactPersonID, ...)` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
| ... | ... | ... |

> Tip: convert a whole schema at once: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables`
```

Only include bullets for conversions that were actually performed on this file (e.g. omit the temporal table bullet if the table has no temporal clauses). Only include the dependency table if there are unresolved dependencies; omit it (and the tip) if all referenced tables already have a postgres output file.

If `geography` columns were converted, append at the end:

```markdown
## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
```

## Step 6 — Print inline summary

After writing both files, print the same summary content to the conversation (do not make the user open the `.md` file to see results). Then print the **"Next files to convert"** section as before:

```
Next files to convert (dependencies of what was just converted):

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
       → required by: Sales.Customers, Sales.Orders, Sales.Invoices

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql
       → required by: Sales.Customers

  Run: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems.sql
       → required by: Sales.InvoiceLines, Sales.OrderLines

  Tip: Convert a whole schema at once:
       /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables
```

This makes it easy to chain conversions until all dependencies are satisfied.

If `geography` columns were found, also print:
"PostGIS extension required — run `CREATE EXTENSION IF NOT EXISTS postgis;` first."
