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

### Prerequisites
- `postgres_15.1` container running
- `wwi_mssql` container present (volume must still exist)
- Schema already applied via Option A
- Python 3 with packages: `pip install pymssql psycopg2-binary`
- `dimitri/pgloader` Docker image: `docker pull dimitri/pgloader`

### Steps

**1. Start the MSSQL container:**
```bash
docker start wwi_mssql
# Wait ~30s for SQL Server to be ready
```

**2. Apply the schema first (if not done):**
```bash
bash scripts/apply-schema.sh --no-seed
```

**3. Run the migration:**
```bash
bash scripts/run-migration.sh
```

This script:
- Resolves both container IPs dynamically (no hardcoded IPs)
- Waits for MSSQL to be ready
- Phase 1: `pgloader` bulk-copies all tables
- Phase 2: `migrate_data.py` re-migrates tables with generated columns (People, StockItems, CustomerTransactions, etc.) that pgloader can't handle
- Phase 3: Syncs all sequences to max IDs

**4. Verify:**
```bash
docker exec postgres_15.1 psql -U postgres -c "SELECT COUNT(*) FROM sales.orders;"
# Expect: ~73,595
```

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
