---
description: Smoke-test a converted PostgreSQL table DDL in the shared postgres_15.1 Docker container using an isolated schema.
argument-hint: <converted-table-sql-file>
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# PostgreSQL Table Smoke Test

Given `$ARGUMENTS` (a single `.sql` file under `postgres/<Schema>/Tables/`):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `postgres/` in a `Tables/` subdirectory.
- If not, print an error and stop:
  ```
  Error: expected a converted table .sql file under postgres/<Schema>/Tables/
  ```
- Extract `<Schema>` (e.g. `Application`) and table file name (e.g. `Cities.sql`).

## Step 2 — Verify container is running

```bash
docker ps --filter name=postgres_15.1 --format '{{.Names}}'
```

If the output is empty, stop with:
```
Error: container postgres_15.1 is not running.
Start it with: docker compose -f /mnt/c/Users/krish/git/AppZ-Images/docker-compose.agentomatic.yml up -d postgres
```

## Step 3 — Create prerequisite schemas

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
CREATE SCHEMA IF NOT EXISTS wwi_test;
CREATE SCHEMA IF NOT EXISTS sequences;
CREATE SCHEMA IF NOT EXISTS <table-schema>;
"
```

Also grep the DDL file for `REFERENCES \w+\.` patterns and pre-create each referenced schema:
```bash
grep -oP 'REFERENCES \K\w+(?=\.)' "$ARGUMENTS" | sort -u | while read s; do
  docker exec postgres_15.1 psql -U postgres -d postgres -c "CREATE SCHEMA IF NOT EXISTS $s;"
done
```

This prevents schema-not-found errors during DDL parsing even before FK constraint stripping takes effect.

## Step 4 — Read and parse the DDL file

Read `$ARGUMENTS`. Extract:
- Table schema and name (from `CREATE TABLE schema.table (`)
- Sequence names (from `CREATE SEQUENCE IF NOT EXISTS sequences.<name>`)
- Whether `geography` type is present anywhere in the file
- `GENERATED ALWAYS AS ... STORED` column names
- CHECK constraint expressions (to inform seed values — e.g. avoid seeding NULL into a column with a `IS NOT NULL` check)
- All column names, types, and nullability/default info (NOT NULL columns with no default must be seeded explicitly)
- Any `-- TODO:` comments in the file

## Step 5 — Apply required extensions

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

If `geography` type was found in Step 4:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

## Step 6 — Apply the table DDL (FK constraints stripped)

Strip FK constraint lines and fix any trailing comma left before the closing `)`, then pipe into the container:

```bash
python3 -c "
import re, sys
sql = open('$ARGUMENTS').read()
# Remove each CONSTRAINT ... FOREIGN KEY ... line (with optional leading comma)
sql = re.sub(r',?\s*\n\s*CONSTRAINT\s+\S+\s+FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', sql)
# Fix trailing comma before closing paren of CREATE TABLE
sql = re.sub(r',(\s*\n\s*\);)', r'\1', sql)
print(sql)
" | docker exec -i postgres_15.1 psql -U postgres -d postgres
```

Capture stdout and stderr. If psql exits non-zero or stderr contains `ERROR:`:
- Print the full error output.
- Print: `Table DDL load failed — fix the above error and re-run /pgtable-test`
- **Stop.** (No stub fallback — the table is the artifact under test, not a dependency to approximate.)

On success: print `  ✓ Table created: schema.table_name`

## Step 7 — Verify table structure

Query `information_schema.columns` to confirm all columns were created:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = '<schema>' AND table_name = '<table>'
ORDER BY ordinal_position;
"
```

Print the column count. Flag any NOT NULL column that has no `column_default` — these must be supplied explicitly in the seed INSERT.

## Step 8 — Verify sequences

For each `sequences.<name>` found in Step 4:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT sequence_name FROM information_schema.sequences
WHERE sequence_schema = 'sequences' AND sequence_name = '<name>';
"
```

Print `  ✓ Sequence exists: sequences.<name>` or `  ✗ Sequence missing: sequences.<name>`.

## Step 9 — Seed one row

Build a minimal INSERT for all NOT NULL columns, using these defaults:

| Column pattern | Seed value |
|---|---|
| PK column with `nextval(...)` default | omit — let the sequence generate the value |
| `*ID` integer (FK column, no default) | `1` |
| Name/text NOT NULL | `'Test Value'` |
| Date NOT NULL | `CURRENT_DATE` |
| Timestamp NOT NULL | `CURRENT_TIMESTAMP` |
| Boolean NOT NULL | `false` |
| `numeric`/`decimal` NOT NULL | `0` |
| `geography` column | `ST_GeogFromText('POINT(0 0)')` |
| GENERATED ALWAYS AS STORED column | omit — PostgreSQL computes it |
| Nullable | omit |

Use `INSERT ... ON CONFLICT DO NOTHING RETURNING *` so the row is returned and re-runs are idempotent:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
INSERT INTO schema.table_name (col1, col2, ...)
VALUES (val1, val2, ...)
ON CONFLICT DO NOTHING RETURNING *;
"
```

If the INSERT fails (e.g. CHECK constraint violation, type mismatch):
- Print the error and the INSERT statement that was attempted.
- Print: `  ⚠ Seed INSERT failed — adjust seed values and re-run. Continuing to SELECT test.`
- Continue to Step 10; do not stop.

## Step 10 — Verify data is readable

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "SELECT * FROM schema.table_name LIMIT 1;"
```

Print the result row(s). If 0 rows and the seed INSERT failed, note that.

## Step 11 — Verify geography columns (if any)

For each geography column detected in Step 4:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT pg_typeof(\"<col>\") FROM schema.table_name LIMIT 1;
"
```

Print `  ✓ Geography column <col>: geography` or flag a type mismatch.

## Step 12 — Verify generated columns (if any)

For each GENERATED ALWAYS AS STORED column detected in Step 4:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres -c "
SELECT \"<col>\" FROM schema.table_name LIMIT 1;
"
```

Print the computed value. If the value is NULL or psql errors:
- Flag it: `  ✗ Generated column <col> returned NULL — expression may use a non-IMMUTABLE function`
- Note: `concat()` is STABLE in PostgreSQL, not IMMUTABLE; replace with `||` in the converted DDL.

## Step 13 — Print FK dependency list

Grep `$ARGUMENTS` for `REFERENCES schema.table` patterns. For each unique (schema, table) pair found:

1. Compute `postgres/<Schema>/Tables/<Table>.sql` (title-case schema and table name).
2. Check whether the file exists.
3. Print:
   - `  ✓ converted: postgres/<Schema>/Tables/<Table>.sql` — file exists
   - `  ✗ missing:   <schema>.<table>` followed by the suggested command:
     `  → /mssql-to-postgres wwi-ssdt/wwi-ssdt/<Schema>/Tables/<Table>.sql`

## Step 14 — Print inline report

```
=== pgtable-test report ===

Container:  postgres_15.1
Table:      schema.table_name
Source:     postgres/<Schema>/Tables/<file>.sql

DDL load:      ✓ Success (FK constraints stripped)
Columns:       <n> columns loaded
Sequences:     sequences.foo_id_seq ✓  |  none
Geography:     location (geography) ✓  |  none
Generated:     SearchName (varchar stored) ✓  |  none

Seed INSERT:   ✓ Success  (row returned below)
               -- or --
               ✗ Failed (see error above)

Row returned:
  (city_id=38187, city_name='Test Value', ...)

SELECT * LIMIT 1:  ✓ Success  |  0 rows

FK dependencies:
  ✓ converted: postgres/Application/Tables/People.sql
  ✗ missing:   application.state_provinces
               → /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/StateProvinces.sql

TODOs in file:
  - (list any -- TODO: comments found in the .sql file, or "none")

Next steps:
  • Convert missing FK deps above, then re-run this test
  • Re-run test:                  /pgtable-test postgres/<Schema>/Tables/<file>.sql
  • Test functions using table:   /pgfunc-test postgres/<Schema>/Functions/<func>.sql
  • Test views using table:       /pgview-test postgres/<Schema>/Views/<view>.sql
```

## Important notes

- **No container lifecycle management** — `postgres_15.1` is shared infrastructure started via `docker-compose.agentomatic.yml`. Never start or stop it.
- Schemas and tables persist between runs. The DDL uses `CREATE TABLE` (not `CREATE TABLE IF NOT EXISTS`) so re-running will produce a `already exists` notice — this is harmless and expected.
- To reset: `docker exec postgres_15.1 psql -U postgres -d postgres -c "DROP TABLE IF EXISTS schema.table_name;"`
- All `docker exec` commands connect as user `postgres` to database `postgres`. This uses local trust auth inside the container — no password needed.
- FK constraints are always stripped for isolation. The FK dependency list in the report tells you what to convert next; once converted, `/pgfunc-test` and `/pgview-test` will pick up the real DDL automatically.
