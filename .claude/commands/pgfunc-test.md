---
description: Smoke-test a converted PL/pgSQL function in the shared postgres_15.1 Docker container using an isolated wwi_test schema.
argument-hint: <converted-function-sql-file>
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# PostgreSQL Function Smoke Test

Given `$ARGUMENTS` (a single `.sql` file under `postgres/<Schema>/Functions/`):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `postgres/`.
- If not, print an error and stop:
  ```
  Error: expected a converted function .sql file under postgres/<Schema>/Functions/
  ```
- Extract `<Schema>` (e.g. `WebApi`) and function file name (e.g. `delete_buying_group.sql`).

## Step 2 — Verify container is running

```bash
docker ps --filter name=postgres_15.1 --format '{{.Names}}'
```

If the output is empty, stop with:
```
Error: container postgres_15.1 is not running.
Start it with: docker compose -f /mnt/c/Users/krish/git/AppZ-Images/docker-compose.agentomatic.yml up -d postgres
```

## Step 3 — Create isolated test schema and prerequisite schemas

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
CREATE SCHEMA IF NOT EXISTS wwi_test;
CREATE SCHEMA IF NOT EXISTS sequences;
"
```

All test objects (stubs, functions, seed data) go into `wwi_test` to avoid polluting other schemas in the shared instance. The `sequences` schema is always pre-created because every converted table DDL that uses a sequence emits `CREATE SEQUENCE IF NOT EXISTS sequences.<name>` — without the schema the statement errors before the table is even reached.

## Step 4 — Read and parse the function file

Read `$ARGUMENTS`. Extract:
- Function schema and name (from `CREATE OR REPLACE FUNCTION schema.name(`)
- Parameter names, types, and count
- `RETURNS` type (`void`, `TABLE(...)`, scalar type)
- All table references (`schema.table`) in the function body
- Whether `pgcrypto` extension is needed (`gen_random_uuid`, `digest`)
- Whether PostGIS is needed (`geography` type)

## Step 5 — Apply required extensions

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

If PostGIS references were found:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

## Step 6 — Apply table dependencies

For each table referenced in the function body (`schema.table`):

1. Compute the expected converted postgres DDL path:
   - `schema.table` → `postgres/<Schema>/Tables/<Table>.sql`
   - Use title-case for the path component (e.g. `sales.orders` → `postgres/Sales/Tables/Orders.sql`)

2. Check if the file exists via Glob.

3. **If the DDL file exists:** attempt to pipe it into the container:
   ```bash
   docker exec -i postgres_15.1 psql -U postgres -d postgres < postgres/<Schema>/Tables/<Table>.sql
   ```
   - If it succeeds: print `  ✓ Applied: postgres/<Schema>/Tables/<Table>.sql`
   - **If it fails** (e.g. PostGIS extension missing, unsatisfied FK deps, immutable expression error): fall through to step 4 to create a targeted stub. Print the error as a warning:
     ```
     ⚠ Full DDL failed (see error above) — applying targeted stub instead
     ```

4. **If the DDL file does not exist, or the apply failed in step 3:** generate and apply a minimal stub containing only the columns the function actually references (from UPDATE/INSERT/SELECT/WHERE clauses in the function body), plus the primary key:
   ```sql
   CREATE TABLE IF NOT EXISTS schema.table (
       "PrimaryKeyCol" integer PRIMARY KEY,
       "Col1" type,
       "Col2" type
       -- stub: full DDL at postgres/<Schema>/Tables/<Table>.sql
   );
   ```
   Apply via psql and print: `  ⚠ Stub created: schema.table`

Note: Use `CREATE TABLE IF NOT EXISTS` so re-runs are idempotent. Known failure causes:
- `geography` column → PostGIS not installed in container
- FK to unconverted table → run `/mssql-to-postgres` on that table first
- `concat()` in `GENERATED ALWAYS AS` → use `||` operator (concat is STABLE not IMMUTABLE)
- `sequences` schema missing → fixed in Step 3 (pre-created unconditionally)

## Step 7 — Generate seed data

For each table that was successfully applied (real DDL or stub), generate minimal `INSERT` statements with representative data. Inspect the real DDL or stub for NOT NULL columns and constraints. Use these defaults:

| Column pattern | Seed value |
|---|---|
| `PersonID`, `UserID`, `LastEditedBy`, `*PersonID` (integer) | `1` |
| `CustomerID` (integer) | `1` |
| `OrderID` (integer) | `1` |
| Name/text columns `NOT NULL` | `'Test Value'` |
| Date columns `NOT NULL` | `CURRENT_DATE` |
| Timestamp columns `NOT NULL` | `CURRENT_TIMESTAMP` |
| Boolean `NOT NULL` | `false` |
| `numeric`/`decimal` `NOT NULL` | `0` |
| Nullable columns | `NULL` (omit from INSERT) |

Use `INSERT ... ON CONFLICT DO NOTHING` to make seeding idempotent:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
INSERT INTO schema.table (col1, col2, ...) VALUES (val1, val2, ...)
ON CONFLICT DO NOTHING;
"
```

Print each seed statement applied.

## Step 8 — Apply the function

```bash
docker exec -i postgres_15.1 psql -U postgres -d postgres < "$ARGUMENTS"
```

Capture stdout and stderr. If psql exits non-zero or stderr contains `ERROR:`:
- Print the full error output
- Print: `Function load failed — fix the above error and re-run /pgfunc-test`
- Stop.

On success: print `  ✓ Function loaded: schema.function_name`

## Step 9 — Generate and run test call

Based on the `RETURNS` type parsed in Step 4:

### `RETURNS void`
```sql
SELECT schema.function_name(null_or_default_arg1, null_or_default_arg2, ...);
```
If the function has no output to verify, print the exit code.

### `RETURNS TABLE(...)`
```sql
SELECT * FROM schema.function_name(null_or_default_arg1, ...) LIMIT 5;
```

### Scalar return
```sql
SELECT schema.function_name(null_or_default_arg1, ...);
```

Build the argument list from the parameters extracted in Step 4:
- `integer` / `bigint` → `0` (or `1` for ID parameters, detected by name ending in `ID`)
- `text` / `varchar` → `NULL::text`
- `boolean` → `false`
- `timestamp` → `CURRENT_TIMESTAMP`
- `date` → `CURRENT_DATE`
- `jsonb` (TVP) → `'[]'::jsonb`
- `numeric` → `0`

Run:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "<test_query>"
```

Add a comment in the output: `-- Note: using default/null args for smoke test. Replace with realistic values for full testing.`

## Step 10 — Post-call verification (for void functions with side effects)

If the function is a DML operation (detected by name prefix: `delete_`, `insert_`, `update_`), run a follow-up SELECT to show the state of the primary affected table:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "SELECT * FROM schema.primary_table LIMIT 5;"
```

This lets you see the effect of the operation.

## Step 11 — Print inline report

```
=== pgfunc-test report ===

Container:  postgres_15.1
Schema:     wwi_test
Function:   schema.function_name(param1 type1, param2 type2, ...) RETURNS <type>
Source:     postgres/<Schema>/Functions/<file>.sql

Dependencies:
  ✓ Applied: postgres/Sales/Tables/Orders.sql
  ⚠ Stub:    application.people  (convert with /mssql-to-postgres)

Seed data applied: <n> rows across <m> tables

Function load: ✓ Success

Test call:
  <test SQL>

Result:
  <psql output or "0 rows" or error>

Post-call state:
  <SELECT output if DML function>

TODOs in function:
  - (list any -- TODO: comments found in the function file)

Next steps:
  • Replace stub tables: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
  • Re-run test: /pgfunc-test postgres/<Schema>/Functions/<file>.sql
  • Test with realistic data: update seed INSERTs in the test call
```

## Important notes

- **No container lifecycle management** — `postgres_15.1` is shared infrastructure started via `docker-compose.agentomatic.yml`. Never start or stop it.
- The `wwi_test` schema persists between runs. All objects use `IF NOT EXISTS` / `CREATE OR REPLACE` — re-runs are safe.
- To reset the test schema: `docker exec postgres_15.1 psql -U postgres -d postgres -c "DROP SCHEMA wwi_test CASCADE; CREATE SCHEMA wwi_test;"`
- All `docker exec` commands connect as user `postgres` to database `postgres`. This uses local trust auth inside the container — no password needed.
