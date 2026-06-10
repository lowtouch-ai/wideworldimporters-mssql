#!/usr/bin/env bash
# Full data migration: MSSQL wwi_mssql → PostgreSQL postgres_15.1
# Run from repo root: bash scripts/run-migration.sh
#
# Prerequisites:
#   - wwi_mssql container running (docker start wwi_mssql)
#   - postgres_15.1 container running
#   - apply-schema.sh already run (tables must exist)
#   - Python packages: pip install pymssql psycopg2-binary

set -euo pipefail

# ── Resolve container IPs dynamically ────────────────────────────────────────
echo "Resolving container IPs..."
MSSQL_IP=$(docker inspect mssql_wwi   --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null | head -1)
PG_IP=$(docker inspect postgres_15.1  --format '{{(index .NetworkSettings.Networks "appz-images_agentomatic_net").IPAddress}}' 2>/dev/null)

if [ -z "$MSSQL_IP" ]; then
  echo "ERROR: mssql_wwi container not running. Run: docker start mssql_wwi"
  exit 1
fi
if [ -z "$PG_IP" ]; then
  echo "ERROR: postgres_15.1 not found on appz-images_agentomatic_net"
  exit 1
fi

echo "  MSSQL:    $MSSQL_IP:1433"
echo "  Postgres: $PG_IP:5432"

# ── Wait for MSSQL to be ready ────────────────────────────────────────────────
echo ""
echo "Waiting for MSSQL to be ready..."
for i in $(seq 1 30); do
  if docker exec mssql_wwi /opt/mssql-tools18/bin/sqlcmd \
      -S localhost -U sa -P "Sp1d3rman!" -Q "SELECT 1" -d WideWorldImporters -C -b 2>/dev/null | grep -q "1"; then
    echo "  MSSQL ready."
    break
  fi
  echo "  Waiting... ($i/30)"
  sleep 3
done

# ── Phase 1: migrate all tables via Python (handles all type/case issues) ─────
echo ""
echo "=== Phase 1: Migrating all tables ==="
docker run --rm \
  --network appz-images_agentomatic_net \
  -v "$(pwd)/scripts:/scripts" \
  -e MSSQL_HOST="$MSSQL_IP" \
  -e PG_HOST="$PG_IP" \
  python:3.12-slim \
  bash -c "pip install -q pymssql psycopg2-binary && python3 /scripts/migrate_data.py"

# ── Phase 3: sync sequences ───────────────────────────────────────────────────
echo ""
echo "=== Phase 3: Sync sequences ==="
docker exec -i postgres_15.1 psql -U postgres -d wideworldimporters -q < postgres/fix_sequences.sql
echo "  Done."

echo ""
echo "=== Migration complete ==="
