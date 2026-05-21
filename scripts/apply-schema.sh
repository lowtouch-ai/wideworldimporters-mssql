#!/usr/bin/env bash
# Apply the full PostgreSQL schema (tables, types, views, functions) and optionally
# seed data to the postgres_15.1 container.
#
# Usage:
#   bash scripts/apply-schema.sh            # apply schema + seed if DB is empty
#   bash scripts/apply-schema.sh --no-seed  # apply schema only, skip seed
#
# Run from repo root. The postgres_15.1 container must already be running.

set -euo pipefail

CONTAINER=postgres_15.1
PG_CMD="docker exec -i $CONTAINER psql -U postgres -d wideworldimporters --set ON_ERROR_STOP=1 -q"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NO_SEED=false

for arg in "$@"; do
  [ "$arg" = "--no-seed" ] && NO_SEED=true
done

# ── helpers ──────────────────────────────────────────────────────────────────

# run <relative-path>
# Fails hard on real errors; treats "already exists" as a warning (idempotent).
run() {
    local file="$REPO_ROOT/$1"
    echo -n "  $(basename "$file") ... "
    result=$(docker exec -i "$CONTAINER" psql -U postgres -d wideworldimporters -q 2>&1 < "$file")
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "✓"
    elif echo "$result" | grep -q "already exists"; then
        echo "⚠ (already exists — skipped)"
    else
        echo "✗"
        echo "$result" | head -20
        exit 1
    fi
}

# run_glob <glob-pattern>  — same idempotency logic, applied to each matched file
run_glob() {
    local pattern="$1"
    for f in $REPO_ROOT/$pattern; do
        [ -f "$f" ] || continue
        echo -n "  $(basename "$f") ... "
        result=$(docker exec -i "$CONTAINER" psql -U postgres -d wideworldimporters -q 2>&1 < "$f")
        local exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo "✓"
        elif echo "$result" | grep -q "already exists"; then
            echo "⚠ (already exists — skipped)"
        else
            echo "✗"
            echo "$result" | head -20
            exit 1
        fi
    done
}

# ── preflight ────────────────────────────────────────────────────────────────

echo "Checking container..."
if ! docker inspect "$CONTAINER" &>/dev/null; then
    echo "ERROR: Container '$CONTAINER' not found. Start it first."
    exit 1
fi
if [ "$(docker inspect -f '{{.State.Running}}' "$CONTAINER")" != "true" ]; then
    echo "ERROR: Container '$CONTAINER' is not running."
    exit 1
fi
echo "  $CONTAINER is running ✓"
echo ""

# ── phase 1: extensions ───────────────────────────────────────────────────────

echo "=== Phase 1: Extensions ==="
if docker exec -i "$CONTAINER" psql -U postgres -d wideworldimporters -q \
    -c "CREATE EXTENSION IF NOT EXISTS postgis;" 2>/dev/null; then
    echo "  postgis ✓"
else
    echo "  postgis ⚠ (not installed on this Postgres image — geography columns will fail)"
fi
if docker exec -i "$CONTAINER" psql -U postgres -d wideworldimporters -q \
    -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" 2>/dev/null; then
    echo "  pgcrypto ✓"
else
    echo "  pgcrypto ⚠ (not available)"
fi
echo ""

# ── phase 2: sequences ────────────────────────────────────────────────────────

echo "=== Phase 2: Sequences ==="
run "postgres/Sequences/Sequences/all_sequences.sql"
echo ""

# ── phase 3: tables (FK dependency order) ─────────────────────────────────────
# Application base tables first (no cross-schema deps except self-ref on People)
# then Warehouse refs, then Purchasing refs, then Sales refs,
# then transactional tables that depend on all of the above.

echo "=== Phase 3: Tables ==="

echo "  -- Application --"
run "postgres/Application/Tables/People.sql"
run "postgres/Application/Tables/Countries.sql"
run "postgres/Application/Tables/StateProvinces.sql"
run "postgres/Application/Tables/Cities.sql"
run "postgres/Application/Tables/DeliveryMethods.sql"
run "postgres/Application/Tables/PaymentMethods.sql"
run "postgres/Application/Tables/TransactionTypes.sql"
run "postgres/Application/Tables/SystemParameters.sql"
run "postgres/Application/Tables/Logs.sql"

echo "  -- Warehouse reference --"
run "postgres/Warehouse/Tables/Colors.sql"
run "postgres/Warehouse/Tables/PackageTypes.sql"
run "postgres/Warehouse/Tables/StockGroups.sql"

echo "  -- Purchasing reference --"
run "postgres/Purchasing/Tables/SupplierCategories.sql"
run "postgres/Purchasing/Tables/Suppliers.sql"

echo "  -- Sales reference --"
run "postgres/Sales/Tables/BuyingGroups.sql"
run "postgres/Sales/Tables/CustomerCategories.sql"
run "postgres/Sales/Tables/Customers.sql"

echo "  -- Warehouse transactional --"
run "postgres/Warehouse/Tables/StockItems.sql"
run "postgres/Warehouse/Tables/StockItemHoldings.sql"
run "postgres/Warehouse/Tables/StockItemStockGroups.sql"

echo "  -- Purchasing transactional --"
run "postgres/Purchasing/Tables/PurchaseOrders.sql"
run "postgres/Purchasing/Tables/PurchaseOrderLines.sql"
run "postgres/Purchasing/Tables/SupplierTransactions.sql"

echo "  -- Sales transactional --"
run "postgres/Sales/Tables/Orders.sql"
run "postgres/Sales/Tables/OrderLines.sql"
run "postgres/Sales/Tables/Invoices.sql"
run "postgres/Sales/Tables/InvoiceLines.sql"
run "postgres/Sales/Tables/CustomerTransactions.sql"
run "postgres/Sales/Tables/SpecialDeals.sql"

echo "  -- Warehouse sensor --"
run "postgres/Warehouse/Tables/StockItemTransactions.sql"
run "postgres/Warehouse/Tables/VehicleTemperatures.sql"
run "postgres/Warehouse/Tables/ColdRoomTemperatures.sql"

echo ""

# ── phase 4: user-defined types ───────────────────────────────────────────────

echo "=== Phase 4: Types ==="
run_glob "postgres/Website/Types/*.sql"
echo ""

# ── phase 5: views ────────────────────────────────────────────────────────────

echo "=== Phase 5: Views ==="
echo "  -- WebApi views --"
run_glob "postgres/WebApi/Views/*.sql"
echo "  -- Website views --"
run_glob "postgres/Website/Views/*.sql"
echo ""

# ── phase 6: functions ────────────────────────────────────────────────────────

echo "=== Phase 6: Functions ==="
echo "  -- Application functions --"
run_glob "postgres/Application/Functions/*.sql"
echo "  -- WebApi functions --"
run_glob "postgres/WebApi/Functions/*.sql"
echo "  -- Website functions --"
run_glob "postgres/Website/Functions/*.sql"
echo "  -- Integration functions --"
run_glob "postgres/Integration/Functions/*.sql"
echo ""

# ── phase 7: fixes (case-sensitivity + array-wrap + sequences) ────────────────
# fix_insert_funcs.sql supersedes fix_jsonb_aliases.sql for insert functions,
# but fix_jsonb_aliases.sql still covers the update functions — apply both.

echo "=== Phase 7: Fixes ==="
run "postgres/fix_jsonb_aliases.sql"
run "postgres/fix_insert_funcs.sql"
echo ""

# ── phase 8: seed data ────────────────────────────────────────────────────────

if [ "$NO_SEED" = true ]; then
    echo "=== Phase 8: Seed (skipped via --no-seed) ==="
else
    PO_COUNT=$(docker exec "$CONTAINER" psql -U postgres -d wideworldimporters -tAq \
        -c "SELECT COUNT(*) FROM purchasing.purchaseorders" 2>/dev/null || echo "0")
    if [ "$PO_COUNT" -gt 0 ]; then
        echo "=== Phase 8: Seed (skipped — DB already has $PO_COUNT purchase orders) ==="
    else
        echo "=== Phase 8: Seed ==="
        bash "$REPO_ROOT/scripts/load-seed.sh"
    fi
fi
echo ""

# ── phase 9: reset sequences to match data ────────────────────────────────────

echo "=== Phase 9: Sync sequences to data ==="
run "postgres/fix_sequences.sql"
echo ""

# ── summary ───────────────────────────────────────────────────────────────────

echo "=== Done ==="
docker exec "$CONTAINER" psql -U postgres -d wideworldimporters -q -c "
SELECT schemaname||'.'||tablename AS table,
  (xpath('/row/cnt/text()', query_to_xml(
    'SELECT COUNT(*) AS cnt FROM '||schemaname||'.'||tablename, false, true, ''
  )))[1]::text::int AS rows
FROM pg_tables
WHERE schemaname IN ('application','sales','purchasing','warehouse')
  AND tablename NOT LIKE '%archive%'
ORDER BY schemaname, tablename;" 2>/dev/null
