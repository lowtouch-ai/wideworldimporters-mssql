#!/usr/bin/env bash
# Load all converted seed scripts into postgres_15.1 in dependency order.
# Run from repo root: bash scripts/load-seed.sh

CONTAINER=postgres_15.1
PG="docker exec -i $CONTAINER psql -U postgres -d wideworldimporters"
SEED_DIR="postgres/seed"

run_script() {
    local file="$1"
    echo -n "  Loading $file ... "
    result=$(docker exec -i $CONTAINER psql -U postgres -d wideworldimporters \
        --set ON_ERROR_STOP=1 -q 2>&1 < "$file")
    if [ $? -eq 0 ]; then
        echo "✓"
    else
        echo "✗"
        echo "$result" | head -20
    fi
}

# Truncate all tables before loading (CASCADE handles FK order)
echo "Truncating tables..."
docker exec $CONTAINER psql -U postgres -d wideworldimporters -q -c "
TRUNCATE
  warehouse.stockitemstockgroups,
  warehouse.stockitemholdings,
  warehouse.stockitemtransactions,
  warehouse.vehicletemperatures,
  warehouse.coldroomtemperatures,
  sales.specialdeals,
  sales.customertransactions,
  sales.invoicelines,
  sales.invoices,
  sales.orderlines,
  sales.orders,
  purchasing.suppliertransactions,
  purchasing.purchaseorderlines,
  purchasing.purchaseorders,
  warehouse.stockitems,
  warehouse.stockgroups,
  warehouse.packagetypes,
  warehouse.colors,
  sales.customers,
  sales.buyinggroups,
  sales.customercategories,
  purchasing.suppliers,
  purchasing.suppliercategories,
  application.systemparameters,
  application.cities,
  application.stateprovinces,
  application.countries,
  application.transactiontypes,
  application.paymentmethods,
  application.deliverymethods,
  application.people
  CASCADE;
" 2>&1 | grep -v "^TRUNCATE"

# Reset sequences before loading
echo "Resetting sequences..."
docker exec $CONTAINER psql -U postgres -d wideworldimporters -q -c "
SELECT setval('sequences.person_id_seq', 1, false);
SELECT setval('sequences.country_id_seq', 1, false);
SELECT setval('sequences.state_province_id_seq', 1, false);
SELECT setval('sequences.city_id_seq', 1, false);
SELECT setval('sequences.delivery_method_id_seq', 1, false);
SELECT setval('sequences.payment_method_id_seq', 1, false);
SELECT setval('sequences.transaction_type_id_seq', 1, false);
SELECT setval('sequences.supplier_category_id_seq', 1, false);
SELECT setval('sequences.supplier_id_seq', 1, false);
SELECT setval('sequences.customer_category_id_seq', 1, false);
SELECT setval('sequences.buying_group_id_seq', 1, false);
SELECT setval('sequences.customer_id_seq', 1, false);
SELECT setval('sequences.color_id_seq', 1, false);
SELECT setval('sequences.package_type_id_seq', 1, false);
SELECT setval('sequences.stock_group_id_seq', 1, false);
SELECT setval('sequences.stock_item_id_seq', 1, false);
" 2>/dev/null || true

echo ""
echo "Loading reference data (in dependency order)..."

# Application reference data first
run_script "$SEED_DIR/pds100-ins-app-people.sql"
run_script "$SEED_DIR/pds110-ins-app-countries.sql"
run_script "$SEED_DIR/pds120-ins-app-deliverymethods.sql"
run_script "$SEED_DIR/pds130-ins-app-paymentmethods.sql"
run_script "$SEED_DIR/pds140-ins-app-stateprovinces.sql"
run_script "$SEED_DIR/pds142-upd-app-stateprovinces-borders.sql"
run_script "$SEED_DIR/pds160-ins-app-transactiontypes.sql"

# Cities (many files, alphabetical)
echo "  Loading cities (a-z)..."
for f in "$SEED_DIR"/pds150-ins-app-cities-*.sql "$SEED_DIR/pds150-ins-app-cities.sql"; do
    [ -f "$f" ] && run_script "$f"
done

# Warehouse reference
run_script "$SEED_DIR/pds190-ins-warehouse-colors.sql"
run_script "$SEED_DIR/pds200-ins-warehouse-packagetypes.sql"
run_script "$SEED_DIR/pds210-ins-warehouse-stockgroups.sql"

# Purchasing reference
run_script "$SEED_DIR/pds170-ins-purchasing-suppliercategories.sql"

# Sales reference
run_script "$SEED_DIR/pds180-ins-sales-groups-categories.sql"

# Purchasing data (depends on categories, cities, people)
run_script "$SEED_DIR/pds220-ins-purchasing-suppliers.sql"

# Sales data (depends on buying groups, customer categories, cities, people)
run_script "$SEED_DIR/pds230-ins-sales-customers.sql"

# Warehouse data (depends on suppliers, people)
run_script "$SEED_DIR/pds240-ins-warehouse-stockitems.sql"
run_script "$SEED_DIR/pds250-ins-warehouse-stockitemholdings.sql"
run_script "$SEED_DIR/pds260-ins-warehouse-stockitemstockgroups.sql"

# System parameters
run_script "$SEED_DIR/pds270-ins-app-systemparameters.sql"

# Purchasing transactional data (depends on suppliers, delivery methods, people, stock items)
run_script "$SEED_DIR/pds280-ins-purchasing-purchaseorders.sql"
run_script "$SEED_DIR/pds290-ins-purchasing-purchaseorderlines.sql"
run_script "$SEED_DIR/pds300-ins-purchasing-suppliertransactions.sql"

# Sales transactional data (depends on customers, stock items, people, delivery methods)
run_script "$SEED_DIR/pds310-ins-sales-orders.sql"
run_script "$SEED_DIR/pds320-ins-sales-orderlines.sql"
run_script "$SEED_DIR/pds330-ins-sales-invoices.sql"
run_script "$SEED_DIR/pds340-ins-sales-invoicelines.sql"
run_script "$SEED_DIR/pds350-ins-sales-customertransactions.sql"

# Unknown order line
run_script "$SEED_DIR/pds400-ins-unkown-orderline.sql"

echo ""
echo "Done. Row counts:"
docker exec $CONTAINER psql -U postgres -d wideworldimporters -c "
SELECT schemaname||'.'||tablename as tbl,
  (xpath('/row/cnt/text()',query_to_xml('SELECT COUNT(*) AS cnt FROM '||schemaname||'.'||tablename,false,true,'')))[1]::text::int AS rows
FROM pg_tables
WHERE schemaname IN ('application','sales','purchasing','warehouse')
  AND tablename NOT LIKE '%archive%'
ORDER BY schemaname,tablename;" 2>/dev/null
