---
description: Smoke-test a converted PostgreSQL table DDL file in the shared postgres_15.1 Docker container using an isolated wwi_test schema.
argument-hint: <converted-table-sql-file>
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# PostgreSQL Table Smoke Test

Given `$ARGUMENTS` (a single `.sql` file under `postgres/<Schema>/Tables/`):

## Step 1 — Validate input

- Confirm `$ARGUMENTS` is a `.sql` file under `postgres/` in a `Tables/` directory.
- If not, print an error and stop:
  ```
  Error: expected a converted table .sql file under postgres/<Schema>/Tables/
  ```
- Extract `<Schema>` (e.g. `Sales`) and table file name (e.g. `Orders.sql`), deriving the table name as the base name without extension.

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
"
```

The `wwi_test` schema is a marker for this test session. The `sequences` schema is always pre-created because table DDL that uses sequences emits `CREATE SEQUENCE IF NOT EXISTS sequences.<name>` — without the schema the statement errors before the table is reached.

## Step 4 — Read and parse the table file

Read `$ARGUMENTS`. Extract:
- Schema name and table name (from `CREATE TABLE schema.table`)
- All `REFERENCES schema.table` FK dependency pairs
- All `nextval('sequences.seq_name')` sequence references
- Whether PostGIS is needed (`geography` type present)
- All column names and types (for the report)

## Step 5 — Apply required extensions

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

If PostGIS references were found (`geography` type):
```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE EXTENSION IF NOT EXISTS postgis;"
```

## Step 6 — Apply sequence stubs

For each `nextval('sequences.seq_name')` reference found in Step 4:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "CREATE SEQUENCE IF NOT EXISTS sequences.seq_name START 1 INCREMENT 1;"
```

Print: `  ✓ Sequence stub: sequences.seq_name`

## Step 7 — Apply FK dependency stubs

For each `REFERENCES schema.table` pair extracted in Step 4:

1. Compute the expected converted postgres DDL path:
   - `schema.table` → `postgres/<Schema>/Tables/<Table>.sql`
   - Use title-case for the path component (e.g. `application.people` → `postgres/Application/Tables/People.sql`)

2. Check if the file exists via Glob.

3. **If the DDL file exists:** apply it with FK constraints stripped:

   **a.** Pre-create all schemas named in `REFERENCES schema.` clauses:
   ```bash
   grep -oP 'REFERENCES \K\w+(?=\.)' postgres/<Schema>/Tables/<Table>.sql | sort -u | \
     while read s; do
       docker exec postgres_15.1 psql -U postgres -d postgres -c "CREATE SCHEMA IF NOT EXISTS $s;"
     done
   ```

   **b.** Strip FK constraint lines and fix any trailing comma before the closing `)`, then pipe into the container:
   ```bash
   python3 -c "
   import re, sys
   sql = open('postgres/<Schema>/Tables/<Table>.sql').read()
   sql = re.sub(r',?\s*\n\s*CONSTRAINT\s+\S+\s+FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', sql)
   sql = re.sub(r',(\s*\n\s*\);)', r'\1', sql)
   print(sql)
   " | docker exec -i postgres_15.1 psql -U postgres -d postgres
   ```
   - Success → print `  ✓ Applied (FK stripped): postgres/<Schema>/Tables/<Table>.sql`
   - **If it still fails:** fall through to step 4, print warning:
     ```
     ⚠ Preprocessed DDL failed (see error above) — applying targeted stub instead
     ```

4. **If the DDL file does not exist, or apply failed:** generate and apply a minimal stub with only the primary key:
   ```sql
   CREATE TABLE IF NOT EXISTS schema.table (
       "PrimaryKeyCol" integer PRIMARY KEY
       -- stub: full DDL at postgres/<Schema>/Tables/<Table>.sql
   );
   ```
   Apply via psql and print: `  ⚠ Stub created: schema.table`

Also apply sequence stubs for any `nextval(...)` references found in dependency DDL files, using the same pattern as Step 6.

## Step 8 — Apply the target table DDL

Apply `$ARGUMENTS` with FK constraints stripped (same python3 stripping technique as Step 7) to avoid blocking on unresolved references:

```bash
python3 -c "
import re, sys
sql = open('$ARGUMENTS').read()
sql = re.sub(r',?\s*\n\s*CONSTRAINT\s+\S+\s+FOREIGN KEY\s*\([^)]+\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', sql)
sql = re.sub(r',(\s*\n\s*\);)', r'\1', sql)
print(sql)
" | docker exec -i postgres_15.1 psql -U postgres -d postgres
```

Capture stdout and stderr. If psql exits non-zero or stderr contains `ERROR:`:
- Print the full error output
- Print: `Table DDL failed — fix the above error and re-run /pgtable-test`
- Stop.

On success: print `  ✓ Table created: schema.table_name`

## Step 9 — Verify table is queryable

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "SELECT * FROM schema.table_name LIMIT 0;"
```

If this succeeds, print: `  ✓ SELECT LIMIT 0: ok`

Also run a column inventory to confirm column count matches source:
```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "SELECT column_name, data_type FROM information_schema.columns WHERE table_schema = 'schema' AND table_name = 'table_name' ORDER BY ordinal_position;"
```

Print the column list.

## Step 10 — Print inline report

```
=== pgtable-test report ===

Container:  postgres_15.1
Table:      schema.table_name
Source:     postgres/<Schema>/Tables/<Table>.sql

Dependencies applied:
  ✓ Applied (FK stripped): postgres/Application/Tables/People.sql
  ⚠ Stub:                  application.cities  (convert with /mssql-to-postgres)

Sequences:
  ✓ sequences.foo_id_seq

Extensions:
  ✓ pgcrypto
  ✓ postgis  (if geography columns present)

Table load:    ✓ Success
SELECT LIMIT 0: ✓ ok

Columns verified (<n> columns):
  OrderID          integer
  CustomerID       integer
  ...

TODOs in DDL:
  - (list any -- NOTE: or -- TODO: comments found in the table file)

Next steps:
  • Replace stub tables: /mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql
  • Re-run test:         /pgtable-test postgres/<Schema>/Tables/<Table>.sql
  • Continue with:       /pgtable-test postgres/<Schema>/Tables/<NextTable>.sql
```

## Step 11 — Write companion test report

Write `postgres/<Schema>/Tables/<Table>.test.md` alongside the `.sql` file:

```markdown
# pgtable-test report: <Schema>.<TableName>

## Source
- **Table file:** `postgres/<Schema>/Tables/<Table>.sql`
- **Test run:** <ISO timestamp>

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.cities` | ⚠ Stub | Run `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.foo_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: <n>

## Column inventory
| Column | Type |
|---|---|
| `OrderID` | integer |
| ... | ... |

## TODOs
- (list any -- NOTE: or -- TODO: comments in the DDL)

## Next steps
- Replace stubs: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/Cities.sql`
- Re-run: `/pgtable-test postgres/<Schema>/Tables/<Table>.sql`
```

## Important notes

- **No container lifecycle management** — `postgres_15.1` is shared infrastructure. Never start or stop it.
- The test applies tables into their real schemas (e.g. `sales`, `application`) within the shared postgres database, not into `wwi_test`. The `wwi_test` schema is a session marker only.
- FK constraints are always stripped when applying DDL in the test environment to prevent cross-table blocking. The `.test.md` report notes which stubs were used.
- All `CREATE` statements use `IF NOT EXISTS` — re-runs are safe.
- To reset and start clean: `docker exec postgres_15.1 psql -U postgres -d postgres -c "DROP SCHEMA wwi_test CASCADE; CREATE SCHEMA wwi_test;"`
- All `docker exec` commands connect as user `postgres` to database `postgres`. No password needed (local trust auth inside container).
