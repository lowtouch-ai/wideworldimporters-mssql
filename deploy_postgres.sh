#!/usr/bin/env bash
# Full deploy: drop wideworldimporters DB, recreate from DDL, seed data.
# Run from repo root: bash deploy_postgres.sh
set -euo pipefail

CONTAINER=postgres_15.1
DB=wideworldimporters
DEPLOY=/tmp/wwi_deploy

phase() { echo; echo "=== [$(date +%H:%M:%S)] $* ==="; }

# Run a file already inside the container
runf() {
    local f="$1"
    echo "  -> $(basename "$f")"
    docker exec "$CONTAINER" psql -U postgres -d "$DB" --set ON_ERROR_STOP=1 -q -f "$f"
}

# Run a specific list of named files from a container-side base dir
run_files() {
    local base="$1"; shift
    for name in "$@"; do
        local f="$base/$name"
        echo "  -> $name"
        docker exec "$CONTAINER" psql -U postgres -d "$DB" --set ON_ERROR_STOP=1 -q -f "$f"
    done
}

# Run all *.sql files in a container-side directory (alphabetical)
run_dir() {
    local dir="$1"
    docker exec "$CONTAINER" bash -c "
        shopt -s nullglob
        for f in \$(ls '$dir'/*.sql 2>/dev/null | sort); do
            echo \"  -> \$(basename \$f)\"
            psql -U postgres -d $DB --set ON_ERROR_STOP=1 -q -f \"\$f\"
        done
    "
}

# ---------------------------------------------------------------------------
# Phase 1: Copy DDL into container
# ---------------------------------------------------------------------------
phase "Copying postgres/ DDL into container"
docker exec "$CONTAINER" rm -rf "$DEPLOY"
docker cp postgres/ "$CONTAINER":"$DEPLOY"

# ---------------------------------------------------------------------------
# Phase 2: Drop + recreate database
# ---------------------------------------------------------------------------
phase "Recreating database '$DB'"
docker exec "$CONTAINER" psql -U postgres \
    -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$DB' AND pid <> pg_backend_pid();" \
    -c "DROP DATABASE IF EXISTS $DB;" \
    -c "CREATE DATABASE $DB;"
docker exec "$CONTAINER" psql -U postgres -d "$DB" \
    -c "CREATE EXTENSION IF NOT EXISTS postgis;" \
    -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"

# ---------------------------------------------------------------------------
# Phase 3: Roles and schemas
# ---------------------------------------------------------------------------
phase "Roles and schemas"
# Roles are database-cluster-wide — run against postgres (default) DB
docker exec "$CONTAINER" psql -U postgres -d postgres --set ON_ERROR_STOP=1 -q \
    -f "$DEPLOY/Security/roles.sql"
runf "$DEPLOY/Security/schemas.sql"

# ---------------------------------------------------------------------------
# Phase 4: Sequences
# ---------------------------------------------------------------------------
phase "Sequences"
run_dir "$DEPLOY/Sequences/Sequences"

# ---------------------------------------------------------------------------
# Phase 5: Tables in FK dependency order
# ---------------------------------------------------------------------------
phase "Tables: Application"
run_files "$DEPLOY/Application/Tables" \
    People.sql People_Archive.sql \
    Countries.sql Countries_Archive.sql \
    StateProvinces.sql StateProvinces_Archive.sql \
    Cities.sql Cities_Archive.sql \
    DeliveryMethods.sql DeliveryMethods_Archive.sql \
    PaymentMethods.sql PaymentMethods_Archive.sql \
    TransactionTypes.sql TransactionTypes_Archive.sql \
    SystemParameters.sql \
    Logs.sql

phase "Tables: Purchasing (base — categories + suppliers)"
run_files "$DEPLOY/Purchasing/Tables" \
    SupplierCategories.sql SupplierCategories_Archive.sql \
    Suppliers.sql Suppliers_Archive.sql

phase "Tables: Warehouse (base — colors, packages, stock)"
run_files "$DEPLOY/Warehouse/Tables" \
    Colors.sql Colors_Archive.sql \
    PackageTypes.sql PackageTypes_Archive.sql \
    StockGroups.sql StockGroups_Archive.sql \
    StockItems.sql StockItems_Archive.sql \
    StockItemHoldings.sql \
    StockItemStockGroups.sql \
    ColdRoomTemperatures.sql ColdRoomTemperatures_Archive.sql \
    VehicleTemperatures.sql

phase "Tables: Purchasing (orders — depend on Suppliers + StockItems)"
run_files "$DEPLOY/Purchasing/Tables" \
    PurchaseOrders.sql \
    PurchaseOrderLines.sql

phase "Tables: Sales"
run_files "$DEPLOY/Sales/Tables" \
    BuyingGroups.sql BuyingGroups_Archive.sql \
    CustomerCategories.sql CustomerCategories_Archive.sql \
    Customers.sql Customers_Archive.sql \
    Orders.sql \
    OrderLines.sql \
    Invoices.sql \
    InvoiceLines.sql \
    CustomerTransactions.sql \
    SpecialDeals.sql

phase "Tables: Purchasing transactions (depend on PurchaseOrders)"
run_files "$DEPLOY/Purchasing/Tables" \
    SupplierTransactions.sql

phase "Tables: Warehouse transactions (depend on Invoices + PurchaseOrders)"
run_files "$DEPLOY/Warehouse/Tables" \
    StockItemTransactions.sql

phase "Tables: DataLoadSimulation"
run_dir "$DEPLOY/DataLoadSimulation/Tables"

# ---------------------------------------------------------------------------
# Phase 6: Composite types
# ---------------------------------------------------------------------------
phase "Composite types (Website)"
run_dir "$DEPLOY/Website/Types"

# ---------------------------------------------------------------------------
# Phase 7: Functions
# ---------------------------------------------------------------------------
phase "Functions: Application"
run_dir "$DEPLOY/Application/Functions"

phase "Functions: Integration"
run_dir "$DEPLOY/Integration/Functions"

phase "Functions: WebApi"
run_dir "$DEPLOY/WebApi/Functions"

phase "Functions: Website"
run_dir "$DEPLOY/Website/Functions"

# Apply function patches (idempotent CREATE OR REPLACE)
if [ -f "$DEPLOY/fix_insert_funcs.sql" ]; then
    phase "Patch: fix_insert_funcs"
    docker exec "$CONTAINER" psql -U postgres -d "$DB" --set ON_ERROR_STOP=1 -q \
        -f "$DEPLOY/fix_insert_funcs.sql"
fi
if [ -f "$DEPLOY/fix_jsonb_aliases.sql" ]; then
    phase "Patch: fix_jsonb_aliases"
    docker exec "$CONTAINER" psql -U postgres -d "$DB" --set ON_ERROR_STOP=1 -q \
        -f "$DEPLOY/fix_jsonb_aliases.sql"
fi

# ---------------------------------------------------------------------------
# Phase 8: Views
# ---------------------------------------------------------------------------
phase "Views: WebApi"
run_dir "$DEPLOY/WebApi/Views"

phase "Views: Website"
run_dir "$DEPLOY/Website/Views"

# ---------------------------------------------------------------------------
# Phase 9: Permissions
# ---------------------------------------------------------------------------
phase "Permissions"
runf "$DEPLOY/Security/permissions.sql"

# ---------------------------------------------------------------------------
# Phase 10: Seed data
# ---------------------------------------------------------------------------
phase "Seed data"
bash scripts/load-seed.sh

# Apply sequence fixup after seeding (realigns sequences to MAX(id))
if [ -f "$DEPLOY/fix_sequences.sql" ]; then
    phase "Patch: fix_sequences (post-seed)"
    docker exec "$CONTAINER" psql -U postgres -d "$DB" --set ON_ERROR_STOP=1 -q \
        -f "$DEPLOY/fix_sequences.sql"
fi

# ---------------------------------------------------------------------------
# Phase 11: Cleanup
# ---------------------------------------------------------------------------
phase "Cleanup"
docker exec "$CONTAINER" rm -rf "$DEPLOY"

# ---------------------------------------------------------------------------
# Done — row-count spot-check
# ---------------------------------------------------------------------------
phase "Deployment complete"
echo
echo "Row counts:"
docker exec "$CONTAINER" psql -U postgres -d "$DB" -c "
  SELECT 'people'       AS table_name, COUNT(*) FROM application.people
  UNION ALL
  SELECT 'customers',                  COUNT(*) FROM sales.customers
  UNION ALL
  SELECT 'stock_items',                COUNT(*) FROM warehouse.stockitems
  UNION ALL
  SELECT 'cities',                     COUNT(*) FROM application.cities
  UNION ALL
  SELECT 'orders',                     COUNT(*) FROM sales.orders
  UNION ALL
  SELECT 'invoices',                   COUNT(*) FROM sales.invoices;
"
