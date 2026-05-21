# Data Load Guide — WideWorldImporters PostgreSQL

Two options depending on what you need:

| Option | Data | When to use |
|---|---|---|
| **Seed data** | ~100 orders, 219 stock items, 14 customers | Dev/demo, no MSSQL needed |
| **Full MSSQL migration** | ~73k orders, full production dataset | Staging/prod, requires `wwi_mssql` container |

---

## Option A — Seed data only (no MSSQL)

### Prerequisites
- `postgres_15.1` container running
- Repo cloned and on branch `11449/migration-docker`

### Steps

**1. Apply schema + seed in one command:**
```bash
bash scripts/apply-schema.sh
```

This runs 9 phases: extensions → sequences → tables → types → views → functions → fixes → seed → sync sequences.

It is **idempotent** — safe to re-run. Already-existing objects are skipped with a warning.

**2. Verify:**
```bash
docker exec postgres_15.1 psql -U postgres -c "
SELECT schemaname||'.'||tablename as tbl,
  (xpath('/row/cnt/text()',query_to_xml('SELECT COUNT(*) AS cnt FROM '||schemaname||'.'||tablename,false,true,'')))[1]::text::int AS rows
FROM pg_tables
WHERE schemaname IN ('application','sales','purchasing','warehouse')
  AND tablename NOT LIKE '%archive%'
ORDER BY schemaname, tablename;"
```

Expected: 100 orders, 500 order lines, 219 stock items, 14 customers, etc.

---

## Option B — Full MSSQL migration (~73k orders)

The server has no MSSQL image — so the workflow is:
1. **Export** SQL files locally (where `wwi_mssql` runs)
2. **Copy** the export folder to the server
3. **Load** on the server using `load-export.sh`

---

### Step 1 — Export from MSSQL locally

Run this on your local machine (where `wwi_mssql` is running):

```bash
mkdir -p export/sql
docker run --rm \
  --network wideworldimporters-mssql_wwi-net \
  -v "$(pwd)/scripts:/scripts" \
  -v "$(pwd)/export:/export" \
  -e MSSQL_HOST=172.20.0.3 \
  python:3.12-slim \
  bash -c "pip install -q pymssql && python3 /scripts/export_to_sql.py"
```

This produces `export/sql/` — 31 `.sql` files (~167MB), one per table, in FK dependency order.

> Already done — the `export/sql/` folder is in this repo.

---

### Step 2 — Copy export folder to server

```bash
scp -r export/sql/ user@your-server:/path/to/wideworldimporters-mssql/export/
```

Or if using the server's file manager / deployment pipeline, copy the entire `export/` folder.

---

### Step 3 — Apply schema on the server

SSH into the server and run from the repo root:

```bash
bash scripts/apply-schema.sh --no-seed
```

---

### Step 4 — Load the exported data on the server

```bash
bash scripts/load-export.sh
```

This script:
- Loads all 31 SQL files into `postgres_15.1` in order
- Disables FK checks during load, re-enables after
- Syncs all sequences to max IDs
- Reports final row counts

**Expected output:**
```
orders               | 73,595
orderlines           | 231,412
invoices             |  70,510
invoicelines         | 228,265
customertransactions |  97,147
```

---

### Re-exporting after MSSQL data changes

If the MSSQL source data changes, re-run Step 1 and repeat Steps 2–4. Each SQL file starts with `TRUNCATE ... CASCADE` so it's safe to reload.

---

## Re-loading from scratch

To wipe everything and start clean:

```bash
# Drop all WWI schemas
docker exec postgres_15.1 psql -U postgres -c "
DROP SCHEMA IF EXISTS application, purchasing, sales, warehouse,
  sequences, webapi, website, integration, dataloadsimulation CASCADE;"

# Then re-apply
bash scripts/apply-schema.sh          # seed data only
# OR
bash scripts/run-migration.sh         # full MSSQL data (after apply-schema.sh --no-seed)
```

---

## Asking Claude to do this for you

If you're in Claude Code (`claude` CLI) on this repo, you can just say:

> "load the seed data" → runs `bash scripts/apply-schema.sh`

> "run the full migration from MSSQL" → starts `wwi_mssql`, runs `bash scripts/run-migration.sh`

> "reset and reload the database" → drops schemas, re-applies

Claude knows this repo — it will check container status, fix any errors, and report row counts when done.

---

## Known limitations

| Issue | Status |
|---|---|
| `geography` / PostGIS columns (`DeliveryLocation`, `Border`, `Location`) | Stored as `TEXT NULL` — spatial queries not supported without PostGIS |
| Sales orders seed is hand-crafted (100 orders) | Use Option B for real volume |
| `wwi_mssql` must still have its Docker volume intact | If volume is gone, the `.bak` restore in `docs/docker-setup.md` is needed |
