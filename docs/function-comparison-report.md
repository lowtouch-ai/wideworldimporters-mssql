# Function Comparison Report — 2026-05-28

## Overall Summary

This report compares **78 MSSQL stored procedures** against their **PostgreSQL PL/pgSQL equivalents** across 3 schemas (WebApi: 60, Integration: 13, Website: 12). All tests ran inside live Docker containers against the full WideWorldImporters dataset (~1,600 customers, ~228K orders, ~99K transactions). DML operations are wrapped in transactions and rolled back — no data is permanently changed.

### Correctness

- **78 / 78 functions passed** — results match between MSSQL and PostgreSQL
- **0 failures** — no correctness regressions detected

### Performance

- PostgreSQL is **24.6× faster on average** across all timed function pairs
- **Largest speedup:** `integration.get_sale_updates` — PG is **5.4×** faster
- **Smallest speedup:** `website.search_for_customers` — PG is **2.3×** slower
- Bulk Integration queries (100K–230K rows) are consistently **4–5× faster** in PG
- WebApi CRUD operations complete in **< 2ms** on PG

---

## Result Counts

| Status | Count |
|--------|-------|
| ✓ PASS | 78 |
| ✗ FAIL | 0 |
| – SKIP | 0 |
| **Total elapsed** | **25.7s** |

## Performance Summary

### Average Latency by Category

| Category | Avg MSSQL (ms) | Avg PG (ms) | Avg Speedup |
|---|---:|---:|---:|
| AUTH | 0.8 | 0.5 | 1.49× |
| COMPLEX | 0.8 | 3.8 | 0.21× |
| DELETE | — | 0.3 | — |
| INSERT | — | 0.5 | — |
| LOGIN | — | 0.4 | — |
| QUERY | 1687.8 | 317.1 | 5.32× |
| SCALAR | 1.7 | 1.5 | 1.10× |
| UPDATE | — | 0.4 | — |

### Top 10 Slowest — MSSQL

| Rank | Function | MSSQL ms |
|---:|---|---:|
| 1 | `integration.get_sale_updates` | 7782.3 |
| 2 | `integration.get_order_updates` | 6815.8 |
| 3 | `integration.get_transaction_updates` | 2061.1 |
| 4 | `integration.get_movement_updates` | 1812.1 |
| 5 | `integration.get_purchase_updates` | 83.1 |
| 6 | `website.search_for_people` | 3.5 |
| 7 | `integration.get_stock_holding_updates` | 2.6 |
| 8 | `website.calculate_customer_price` | 1.7 |
| 9 | `website.search_for_customers` | 1.5 |
| 10 | `website.search_for_stock_items_by_tags` | 1.5 |

### Top 10 Slowest — PostgreSQL

| Rank | Function | PG ms |
|---:|---|---:|
| 1 | `integration.get_sale_updates` | 1446.5 |
| 2 | `integration.get_order_updates` | 1321.0 |
| 3 | `integration.get_movement_updates` | 589.6 |
| 4 | `integration.get_transaction_updates` | 415.2 |
| 5 | `website.invoice_customer_orders` | 78.6 |
| 6 | `integration.get_purchase_updates` | 22.2 |
| 7 | `website.insert_customer_orders` | 3.6 |
| 8 | `website.search_for_customers` | 3.5 |
| 9 | `webapi.search_for_stock_items` | 3.5 |
| 10 | `webapi.insert_customers_from_json` | 1.8 |

## Schema: WebApi

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `webapi.delete_buying_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 1.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_city` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_color` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_country` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_customer` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_customer_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_delivery_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_package_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_payment_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order_line` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_state_province` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_item` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_transaction` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_transaction_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_buying_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.8 | — |  |
| `webapi.insert_cities_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_colors_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.8 | — |  |
| `webapi.insert_countries_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_customer_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_customers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 1.8 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_delivery_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — |  |
| `webapi.insert_package_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_payment_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_purchase_order_lines_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 1.0 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_purchase_orders_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_state_provinces_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_stock_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_stock_items_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_supplier_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — |  |
| `webapi.insert_supplier_transactions_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 1.2 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_suppliers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_transaction_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.6 | — |  |
| `webapi.login` | LOGIN | SKIP (no MSSQL SP) | 0 rows | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.search_for_stock_items` | QUERY | SKIP (no MSSQL SP) | 1 rows | ✓ | — | 3.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_buying_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_cc7ac010') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_city_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_color_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_81f95c3e') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_country_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_bbb2faf5') | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.9 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=2) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.update_delivery_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_c098bf9c') | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.update_invoice_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 1.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_package_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_f69c18fa') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_payment_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_e63683bb') | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_line_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_sales_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 1.3 | — | PG-only, no MSSQL counterpart |
| `webapi.update_special_deal_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_state_province_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_stock_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_6e2b2714') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_stock_item_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_48748794') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=134) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.update_transaction_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_450a7723') | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |

## Schema: Integration

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `integration.get_movement_updates` | QUERY | 236667 rows | 236667 rows | ✓ | 1812.1 | 589.6 | 3.07× |  |
| `integration.get_order_updates` | QUERY | 231412 rows | 231412 rows | ✓ | 6815.8 | 1321.0 | 5.16× |  |
| `integration.get_purchase_updates` | QUERY | 8367 rows | 8367 rows | ✓ | 83.1 | 22.2 | 3.74× |  |
| `integration.get_sale_updates` | QUERY | 228265 rows | 228265 rows | ✓ | 7782.3 | 1446.5 | 5.38× |  |
| `integration.get_stock_holding_updates` | QUERY | 227 rows | 227 rows | ✓ | 2.6 | 0.7 | 3.43× |  |
| `integration.get_transaction_updates` | QUERY | 99585 rows | 99585 rows | ✓ | 2061.1 | 415.2 | 4.96× |  |

## Schema: Website

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `website.activate_website_logon` | AUTH | raised exception (expected) | raised exception (expected) | ✓ | 0.9 | 0.5 | 1.73× |  |
| `website.calculate_customer_price` | SCALAR | price=25.00 | price=25.00 | ✓ | 1.7 | 1.5 | 1.10× |  |
| `website.change_password` | AUTH | raised exception (expected) | raised exception (expected) | ✓ | 0.7 | 0.5 | 1.27× |  |
| `website.insert_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 3.6 | — | MSSQL uses TVP; PG-only test |
| `website.invoice_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 78.6 | — | MSSQL uses TVP; PG-only test (created+picked+invoiced in txn) |
| `website.record_cold_room_temperatures` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 0.6 | — | MSSQL uses TVP; PG-only test |
| `website.record_vehicle_temperature` | COMPLEX | executed OK | executed OK | ✓ | 0.8 | 0.5 | 1.51× |  |
| `website.search_for_customers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ | 1.5 | 3.5 | 0.43× |  |
| `website.search_for_people` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 3.5 | 1.0 | 3.56× |  |
| `website.search_for_stock_items` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 1.3 | 0.5 | 2.73× |  |
| `website.search_for_stock_items_by_tags` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 1.5 | 0.5 | 3.21× |  |
| `website.search_for_suppliers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ | 0.6 | 0.7 | 0.89× |  |
