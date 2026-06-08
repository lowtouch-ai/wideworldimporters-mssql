#!/usr/bin/env bash
# Validate WideWorldImporters data migration: MSSQL → PostgreSQL
# Run from repo root: bash scripts/run-validation.sh
#
# Prerequisites:
#   - mssql_wwi container running  (docker start mssql_wwi)
#   - postgres_15.1 container running
#   - Migration already completed  (scripts/run-migration.sh)
#
# Output: docs/validation-report.md
# Exit code: 0 = all tables pass, 1 = one or more failures

set -euo pipefail

# ── Resolve container IPs dynamically ─────────────────────────────────────────
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

# ── Wait for MSSQL to be ready ─────────────────────────────────────────────────
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

# ── Run validation in ephemeral Python container ───────────────────────────────
echo ""
echo "=== Running data validation (31 tables) ==="
mkdir -p docs
docker run --rm \
  --network appz-images_agentomatic_net \
  -v "$(pwd):/repo" \
  -e MSSQL_HOST="$MSSQL_IP" \
  -e PG_HOST="$PG_IP" \
  -e REPORT_PATH="/repo/docs/validation-report.md" \
  python:3.12-slim \
  bash -c "pip install -q pymssql psycopg2-binary && python3 /repo/scripts/validate_migration.py"

echo ""
echo "=== Validation complete ==="
echo "Report: docs/validation-report.md"
