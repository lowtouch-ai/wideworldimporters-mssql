---
description: List all dependencies of a MSSQL source or converted postgres .sql file, showing which are already converted and which still need conversion.
argument-hint: <sql-file-path>
allowed-tools: [Read, Glob, Grep]
---

# MSSQL Dependency Checker

Given `$ARGUMENTS` (a single `.sql` file — either MSSQL source under `wwi-ssdt/` or converted postgres output under `postgres/`):

## Step 1 — Read the file

Read `$ARGUMENTS`. If the file does not exist, print:
```
Error: file not found: $ARGUMENTS
```
and stop.

## Step 2 — Detect object type

Scan the file content for these patterns (in order):
- `CREATE TABLE` → **table**
- `CREATE PROCEDURE` or `CREATE OR REPLACE FUNCTION` with body containing procedural logic → **stored procedure** or **function**
- `CREATE VIEW` → **view**

## Step 3 — Extract dependencies

### For TABLE files

**FK dependencies** — scan for all `REFERENCES` clauses:
- MSSQL pattern: `REFERENCES [Schema].[Table]`
- Postgres pattern: `REFERENCES schema.table`
- Extract each unique `schema.table` pair (lowercase both parts)
- Exclude self-references (same table being defined)

**Sequence dependencies** — scan for:
- MSSQL: `NEXT VALUE FOR [Sequences].[X]` → sequence name `sequences.x_seq` (snake_case)
- Postgres: `nextval('sequences.x_seq')`

### For STORED PROCEDURE / FUNCTION files

**Table references** — scan the body for `[Schema].[Table]` or `schema.table` patterns following these keywords: `FROM`, `JOIN`, `INTO`, `UPDATE`, `DELETE FROM`, `INSERT INTO`. Lowercase both parts. Deduplicate.

**Sequence references** — scan for:
- `NEXT VALUE FOR [Sequences].[X]`
- `nextval('sequences.x_seq')`

**TVP / UDT references** — scan parameters for `[Schema].[TypeName] READONLY` or `Schema.TypeName READONLY`. Record as type `udt`.

**View / function calls** — scan for `[Schema].[Name]` in `FROM` or function-call positions that are not tables. Flag these as type `view/func` for awareness (not blocking).

Deduplicate all references. Ignore the object's own schema+name.

### For VIEW files

Apply the same table/function scanning as stored procedures above.

## Step 4 — Resolve status for each dependency

For each dependency (type: `table`, `sequence`, `udt`, `view/func`):

1. Compute the **MSSQL source path**:
   - Table: `wwi-ssdt/wwi-ssdt/<Schema>/Tables/<Table>.sql` (title-case Schema, PascalCase Table)
   - Sequence: inline in consuming table — mark as `n/a`
   - UDT: `wwi-ssdt/wwi-ssdt/<Schema>/User Defined Types/<TypeName>.sql`
   - View: `wwi-ssdt/wwi-ssdt/<Schema>/Views/<Name>.sql`

2. Compute the **Postgres output path**:
   - Table: `postgres/<Schema>/Tables/<Table>.sql`
   - Function: `postgres/<Schema>/Functions/<snake_name>.sql`
   - View: `postgres/<Schema>/Views/<snake_name>.sql`
   - Sequence: `n/a` (emitted inline)

3. Check existence via Glob. Set **status**:
   - `✓ converted` — postgres output file exists
   - `✗ missing` — postgres output file does not exist (MSSQL source may or may not exist)
   - `n/a` — not applicable (sequences inline, self-refs)

## Step 5 — Print report

```
Dependencies of: <file path>
Object type:     <TABLE | STORED PROCEDURE | FUNCTION | VIEW>

┌──────────────────────────────────┬──────────┬──────────────────────────────────────────────────┬─────────────┐
│ Dependency                       │ Type     │ Postgres file                                    │ Status      │
├──────────────────────────────────┼──────────┼──────────────────────────────────────────────────┼─────────────┤
│ application.people               │ table    │ postgres/Application/Tables/People.sql           │ ✗ missing   │
│ sales.customers                  │ table    │ postgres/Sales/Tables/Customers.sql              │ ✓ converted │
│ sequences.order_id_seq           │ sequence │ n/a (inline)                                     │ n/a         │
└──────────────────────────────────┴──────────┴──────────────────────────────────────────────────┴─────────────┘
```

If there are missing dependencies, list them with suggested conversion commands:

```
Missing conversions — run in this order:
  /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
  /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql
```

For stored procedure / function files, also suggest the appropriate next step:

```
When all table dependencies are satisfied:
  /mssql-to-pgfunc  "<file>"    ← to convert SP to PL/pgSQL function
  /mssql-to-api     "<file>"    ← to convert SP to FastAPI endpoint
```

If all dependencies are already converted:
```
All dependencies satisfied ✓
Ready to run:
  /mssql-to-postgres "<file>"   (for table DDL)
  /mssql-to-pgfunc   "<file>"   (for stored procedure)
```

## Important notes

- This command is **read-only** — it never writes files or modifies anything.
- Run it before any conversion command to understand what needs to be done first.
- Self-referencing FKs (e.g. `Sales.Orders → Sales.Orders` for `BackorderOrderID`) are listed as `n/a` and do not block conversion.
