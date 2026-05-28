# Function Comparison Report — 2026-05-28

## Summary

| Status | Count |
|--------|-------|
| ✓ PASS | 78 |
| ✗ FAIL | 0 |
| – SKIP | 0 |
| **Total elapsed** | **25.5s** |

## Performance Summary

### Average Latency by Category

| Category | Avg MSSQL (ms) | Avg PG (ms) | Avg Speedup |
|---|---:|---:|---:|
| AUTH | 0.7 | 0.5 | 1.45× |
| COMPLEX | 0.8 | 3.8 | 0.20× |
| DELETE | — | 0.4 | — |
| INSERT | — | 0.5 | — |
| LOGIN | — | 0.4 | — |
| QUERY | 1651.1 | 320.2 | 5.16× |
| SCALAR | 0.5 | 1.5 | 0.32× |
| UPDATE | — | 0.5 | — |

### Top 10 Slowest — MSSQL

| Rank | Function | MSSQL ms |
|---:|---|---:|
| 1 | `integration.get_sale_updates` | 7631.8 |
| 2 | `integration.get_order_updates` | 6654.8 |
| 3 | `integration.get_transaction_updates` | 2000.1 |
| 4 | `integration.get_movement_updates` | 1784.3 |
| 5 | `integration.get_purchase_updates` | 80.7 |
| 6 | `website.search_for_people` | 3.3 |
| 7 | `integration.get_stock_holding_updates` | 2.7 |
| 8 | `website.search_for_stock_items_by_tags` | 1.5 |
| 9 | `website.search_for_customers` | 1.4 |
| 10 | `website.search_for_stock_items` | 1.2 |

### Top 10 Slowest — PostgreSQL

| Rank | Function | PG ms |
|---:|---|---:|
| 1 | `integration.get_sale_updates` | 1463.7 |
| 2 | `integration.get_order_updates` | 1337.2 |
| 3 | `integration.get_movement_updates` | 594.3 |
| 4 | `integration.get_transaction_updates` | 413.8 |
| 5 | `website.invoice_customer_orders` | 77.8 |
| 6 | `integration.get_purchase_updates` | 22.3 |
| 7 | `webapi.search_for_stock_items` | 4.6 |
| 8 | `website.search_for_customers` | 3.2 |
| 9 | `website.insert_customer_orders` | 2.5 |
| 10 | `webapi.update_supplier_transaction_from_json` | 1.8 |

## Schema: WebApi

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `webapi.delete_buying_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 1.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_city` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_color` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_country` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_customer` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_customer_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_delivery_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_package_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_payment_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order_line` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_state_province` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_item` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_transaction` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.3 | — | PG-only, no MSSQL counterpart |
| `webapi.delete_transaction_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | — | 0.2 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_buying_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.8 | — |  |
| `webapi.insert_cities_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_colors_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — |  |
| `webapi.insert_countries_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_customer_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.9 | — |  |
| `webapi.insert_customers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 1.1 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_delivery_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_package_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_payment_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_purchase_order_lines_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_purchase_orders_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_state_provinces_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_stock_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_stock_items_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_supplier_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.insert_supplier_transactions_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_suppliers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.insert_transaction_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | — | 0.4 | — |  |
| `webapi.login` | LOGIN | SKIP (no MSSQL SP) | 0 rows | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.search_for_stock_items` | QUERY | SKIP (no MSSQL SP) | 1 rows | ✓ | — | 4.6 | — | PG-only, no MSSQL counterpart |
| `webapi.update_buying_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_7411694d') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_city_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_color_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_0e25c943') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_country_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_889dc0c7') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.update_customer_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=2) | ✓ | — | 0.9 | — | PG-only, no MSSQL counterpart |
| `webapi.update_delivery_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_2f9cb525') | ✓ | — | 0.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_invoice_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 1.4 | — | PG-only, no MSSQL counterpart |
| `webapi.update_package_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_b5abecdb') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_payment_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_f72ddebd') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_line_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.6 | — | PG-only, no MSSQL counterpart |
| `webapi.update_sales_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 1.1 | — | PG-only, no MSSQL counterpart |
| `webapi.update_special_deal_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.update_state_province_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_stock_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_611c20df') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_stock_item_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.7 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_a1b0f6a8') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | — | 0.8 | — | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=134) | ✓ | — | 1.8 | — | PG-only, no MSSQL counterpart |
| `webapi.update_transaction_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_49e1bd62') | ✓ | — | 0.5 | — | PG-only, no MSSQL counterpart |

## Schema: Integration

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `integration.get_movement_updates` | QUERY | 236667 rows | 236667 rows | ✓ | 1784.3 | 594.3 | 3.00× |  |
| `integration.get_order_updates` | QUERY | 231412 rows | 231412 rows | ✓ | 6654.8 | 1337.2 | 4.98× |  |
| `integration.get_purchase_updates` | QUERY | 8367 rows | 8367 rows | ✓ | 80.7 | 22.3 | 3.62× |  |
| `integration.get_sale_updates` | QUERY | 228265 rows | 228265 rows | ✓ | 7631.8 | 1463.7 | 5.21× |  |
| `integration.get_stock_holding_updates` | QUERY | 227 rows | 227 rows | ✓ | 2.7 | 0.8 | 3.36× |  |
| `integration.get_transaction_updates` | QUERY | 99585 rows | 99585 rows | ✓ | 2000.1 | 413.8 | 4.83× |  |

## Schema: Website

| Function | Category | MSSQL Result | PG Result | Match | MSSQL ms | PG ms | Speedup | Notes |
|---|---|---|---|:---:|---:|---:|---:|---|
| `website.activate_website_logon` | AUTH | raised exception (expected) | raised exception (expected) | ✓ | 0.8 | 0.5 | 1.54× |  |
| `website.calculate_customer_price` | SCALAR | price=25.00 | price=25.00 | ✓ | 0.5 | 1.5 | 0.32× |  |
| `website.change_password` | AUTH | raised exception (expected) | raised exception (expected) | ✓ | 0.5 | 0.4 | 1.32× |  |
| `website.insert_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 2.5 | — | MSSQL uses TVP; PG-only test |
| `website.invoice_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 77.8 | — | MSSQL uses TVP; PG-only test (created+picked+invoiced in txn) |
| `website.record_cold_room_temperatures` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | — | 0.6 | — | MSSQL uses TVP; PG-only test |
| `website.record_vehicle_temperature` | COMPLEX | executed OK | executed OK | ✓ | 0.8 | 0.9 | 0.82× |  |
| `website.search_for_customers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ | 1.4 | 3.2 | 0.43× |  |
| `website.search_for_people` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 3.3 | 1.0 | 3.44× |  |
| `website.search_for_stock_items` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 1.2 | 0.5 | 2.59× |  |
| `website.search_for_stock_items_by_tags` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ | 1.5 | 0.6 | 2.49× |  |
| `website.search_for_suppliers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ | 0.8 | 0.8 | 0.93× |  |
