---
description: Smoke-test a converted PostgreSQL view in the shared postgres_15.1 Docker container using an isolated wwi_test schema.
argument-hint: <converted-view-sql-file>
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# PostgreSQL View Smoke Test

Given `$ARGUMENTS` (a single `.sql` file under `postgres/<Schema>/Views/`):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `postgres/`.
- If not, print an error and stop:
  ```
  Error: expected a converted view .sql file under postgres/<Schema>/Views/
  ```
- Extract `<Schema>` (e.g. `WebApi`) and view file name (e.g. `Customers.sql`).

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

All test objects (stubs, views, seed data) go into `wwi_test` to avoid polluting other schemas in the shared instance.

## Step 4 — Read and parse the view file

Read `$ARGUMENTS`. Extract:
- View schema and name (from `CREATE OR REPLACE VIEW schema.name`)
- All table and view references (`schema.object`) from `FROM` and `JOIN` clauses, including subqueries
- Whether PostGIS is needed (`ST_X`, `ST_Y`, `geography`, `::geometry`)
- Whether `json_build_object` / `jsonb` operations are present
- Any `-- TODO:` comments in the file

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

## Step 6 — Apply table and view dependencies

For each object referenced in the view body (`schema.table_or_view`):

### Tables

1. Compute the expected converted postgres DDL path:
   - `schema.table` → `postgres/<Schema>/Tables/<Table>.sql`
   - Use title-case for the path component (e.g. `sales.customers` → `postgres/Sales/Tables/Customers.sql`)

2. Check if the file exists via Glob.

3. **If the DDL file exists:** apply it with FK constraints stripped:

   **a.** Pre-create all schemas named in `REFERENCES schema.` clauses:
   ```bash
   grep -oP 'REFERENCES \K\w+(?=\.)' postgres/<Schema>/Tables/<Table>.sql | sort -u | \
     while read s; do
       docker exec postgres_15.1 psql -U postgres -d postgres -c "CREATE SCHEMA IF NOT EXISTS $s;"
     done
   ```

   **b.** Strip FK constraint lines and fix trailing commas, then pipe into the container:
   ```bash
   python3 -c "
   import re, sys
   sql = open('postgres/<Schema>/Tables/<Table>.sql').read()
   sql = re.sub(r',?\s*\n\s*CONSTRAINT\s+\S+\s+FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', sql)
   sql = re.sub(r',(\s*\n\s*\);)', r'\1', sql)
   print(sql)
   " | docker exec -i postgres_15.1 psql -U postgres -d postgres
   ```
   - If it succeeds: print `  ✓ Applied (FK constraints stripped): postgres/<Schema>/Tables/<Table>.sql`
   - **If it still fails:** fall through to stub. Print the error as a warning:
     ```
     ⚠ Preprocessed DDL failed (see error above) — applying targeted stub instead
     ```

4. **If the DDL file does not exist, or the apply failed:** generate and apply a minimal stub containing only the columns the view actually references (from SELECT, WHERE, and JOIN ON clauses), plus a synthetic primary key:
   ```sql
   CREATE TABLE IF NOT EXISTS schema.table (
       id integer PRIMARY KEY,
       "Col1" type,
       "Col2" type
       -- stub: full DDL at postgres/<Schema>/Tables/<Table>.sql
   );
   ```
   Apply via psql and print: `  ⚠ Stub created: schema.table`

### Dependent views

If the view references another view (`schema.view_name` that resolves to `postgres/<Schema>/Views/<View>.sql`):

1. Check if the converted view file exists.
2. If it exists, apply it recursively (same process: apply its own table deps first, then the view itself).
3. If it does not exist, generate a minimal stub view:
   ```sql
   CREATE OR REPLACE VIEW schema.view_name AS SELECT 1::integer AS id;
   -- stub: convert with /mssql-to-pgview
   ```
   Print: `  ⚠ Stub view created: schema.view_name`

Use `CREATE TABLE IF NOT EXISTS` and `CREATE OR REPLACE VIEW` so re-runs are idempotent.

## Step 7 — Generate seed data

For each table that was successfully applied (real DDL or stub), generate minimal `INSERT` statements. Inspect the real DDL or stub for NOT NULL columns. Use these defaults:

| Column pattern | Seed value |
|---|---|
| `*ID` integer | `1` |
| Name/text columns `NOT NULL` | `'Test Value'` |
| Date columns `NOT NULL` | `CURRENT_DATE` |
| Timestamp columns `NOT NULL` | `CURRENT_TIMESTAMP` |
| Boolean `NOT NULL` | `false` |
| `numeric`/`decimal` `NOT NULL` | `0` |
| `geography` columns | `ST_GeogFromText('POINT(0 0)')` |
| Nullable columns | omit from INSERT |

Use `INSERT ... ON CONFLICT DO NOTHING` for idempotency:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
INSERT INTO schema.table (col1, col2, ...) VALUES (val1, val2, ...)
ON CONFLICT DO NOTHING;
"
```

Print each seed statement applied.

## Step 8 — Apply the view

```bash
docker exec -i postgres_15.1 psql -U postgres -d postgres < "$ARGUMENTS"
```

Capture stdout and stderr. If psql exits non-zero or stderr contains `ERROR:`:
- Print the full error output
- Print: `View load failed — fix the above error and re-run /pgview-test`
- Stop.

On success: print `  ✓ View loaded: schema.view_name`

## Step 9 — Run smoke-test SELECT

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "SELECT * FROM schema.view_name LIMIT 5;"
```

Capture stdout and stderr.

- If it fails: print the error and stop with `View SELECT failed — see error above`.
- If it returns rows: print them. Print `  ✓ View returns rows`.
- If it returns 0 rows: print `  ✓ View executes without error (0 rows — seed more data for a non-empty result)`.

### JSON column verification

If the view contains `json_build_object(...)` columns (detected from the `.sql` file), also run:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT pg_typeof(<json_col>) FROM schema.view_name LIMIT 1;
"
```
Confirm the type is `json` or `jsonb`. Print `  ✓ JSON column <col> type: json` or flag a mismatch.

### PostGIS column verification

If the view contains `ST_X`/`ST_Y` calls, also verify the result is numeric:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT pg_typeof(<spatial_col>) FROM schema.view_name LIMIT 1;
"
```
Print `  ✓ Spatial column <col> type: double precision` or flag a mismatch.

## Step 10 — Print inline report

```
=== pgview-test report ===

Container:  postgres_15.1
View:       schema.view_name
Source:     postgres/<Schema>/Views/<file>.sql

Dependencies:
  ✓ Applied (FK stripped): postgres/Sales/Tables/Customers.sql
  ✓ Applied (FK stripped): postgres/Application/Tables/People.sql
  ⚠ Stub table:            sales.buying_groups  (convert with /mssql-to-postgres)
  ⚠ Stub view:             webapi.cities         (convert with /mssql-to-pgview)

Seed data applied: <n> rows across <m> tables

View load: ✓ Success

Test query:
  SELECT * FROM schema.view_name LIMIT 5;

Result:
  <psql output or "0 rows">

Column type checks:
  ✓ DeliveryLocation — json
  ✓ DeliveryLat      — double precision (PostGIS)

TODOs in view:
  - (list any -- TODO: comments found in the view file)

Next steps:
  • Replace stub tables:  /mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups.sql
  • Replace stub views:   /mssql-to-pgview wwi-ssdt/wwi-ssdt/WebApi/Views/Cities.sql
  • Re-run test:          /pgview-test postgres/<Schema>/Views/<file>.sql
  • Seed realistic data:  update INSERT values above for a non-empty result
```

## Important notes

- **No container lifecycle management** — `postgres_15.1` is shared infrastructure. Never start or stop it.
- The `wwi_test` schema persists between runs. All objects use `IF NOT EXISTS` / `CREATE OR REPLACE` — re-runs are safe.
- To reset the test schema: `docker exec postgres_15.1 psql -U postgres -d postgres -c "DROP SCHEMA wwi_test CASCADE; CREATE SCHEMA wwi_test;"`
- All `docker exec` commands connect as user `postgres` to database `postgres` using local trust auth — no password needed.
- Views are read-only — no post-call state check is needed.
