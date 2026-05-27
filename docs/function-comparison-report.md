# Function Comparison Report — 2026-05-27

## Summary

| Status | Count |
|--------|-------|
| ✓ PASS | 78 |
| ✗ FAIL | 0 |
| ⚠ WARN | 7 |
| – SKIP | 0 |
| **Elapsed** | **25.4s** |

## Schema: WebApi

| Function | Category | MSSQL Result | PG Result | Match | Notes |
|---|---|---|---|:---:|---|
| `webapi.delete_buying_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_city` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_color` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_country` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_customer` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_customer_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_delivery_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_package_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_payment_method` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_purchase_order_line` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_state_province` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_group` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_stock_item` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_category` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_supplier_transaction` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.delete_transaction_type` | DELETE | SKIP (no MSSQL SP) | deleted OK (count=0) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_buying_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_cities_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_colors_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_countries_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_customer_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_customers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_delivery_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_package_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_payment_methods_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_purchase_order_lines_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_purchase_orders_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_state_provinces_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_stock_groups_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_stock_items_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_supplier_categories_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.insert_supplier_transactions_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_suppliers_from_json` | COMPLEX | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.insert_transaction_types_from_json` | INSERT | SKIP (no MSSQL SP) | inserted OK (count=1) | ✓ |  |
| `webapi.login` | LOGIN | SKIP (no MSSQL SP) | 0 rows | ✓ | PG-only, no MSSQL counterpart |
| `webapi.search_for_stock_items` | QUERY | SKIP (no MSSQL SP) | 1 rows | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_buying_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_3a2b2674') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_city_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_color_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_9aed3125') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_country_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_customer_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_4f6c5d52') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_customer_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_customer_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=2) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_delivery_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_93c23396') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_invoice_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_package_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_af245b59') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_payment_method_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_5562633a') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_purchase_order_line_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_sales_order_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_special_deal_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_state_province_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_stock_group_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_6b5cdd0d') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_stock_item_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_category_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_63c43ce8') | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=1) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_supplier_transaction_from_json` | COMPLEX | SKIP (no MSSQL SP) | updated OK (id=134) | ✓ | PG-only, no MSSQL counterpart |
| `webapi.update_transaction_type_from_json` | UPDATE | SKIP (no MSSQL SP) | updated OK (match=True, val='Updated_bba36da8') | ✓ | PG-only, no MSSQL counterpart |

## Schema: Integration

| Function | Category | MSSQL Result | PG Result | Match | Notes |
|---|---|---|---|:---:|---|
| `integration.get_city_updates` | QUERY | 78354 rows | ERROR: relation "application.countries_archive" does not exi | ⚠ | PG archive tables not migrated |
| `integration.get_customer_updates` | QUERY | 0 rows | ERROR: relation "sales.buyinggroups_archive" does not exist
 | ⚠ | PG archive tables not migrated |
| `integration.get_employee_updates` | QUERY | 193 rows | ERROR: relation "application.people_archive" does not exist
 | ⚠ | PG archive tables not migrated |
| `integration.get_movement_updates` | QUERY | 236667 rows | 236667 rows | ✓ |  |
| `integration.get_order_updates` | QUERY | 231412 rows | 231412 rows | ✓ |  |
| `integration.get_payment_method_updates` | QUERY | 1 rows | ERROR: relation "application.paymentmethods_archive" does no | ⚠ | PG archive tables not migrated |
| `integration.get_purchase_updates` | QUERY | 8367 rows | 8367 rows | ✓ |  |
| `integration.get_sale_updates` | QUERY | 228265 rows | 228265 rows | ✓ |  |
| `integration.get_stock_holding_updates` | QUERY | 227 rows | 227 rows | ✓ |  |
| `integration.get_stock_item_updates` | QUERY | 452 rows | ERROR: relation "warehouse.stockitems_archive" does not exis | ⚠ | PG archive tables not migrated |
| `integration.get_supplier_updates` | QUERY | 14 rows | ERROR: relation "purchasing.suppliercategories_archive" does | ⚠ | PG archive tables not migrated |
| `integration.get_transaction_type_updates` | QUERY | 2 rows | ERROR: relation "application.transactiontypes_archive" does  | ⚠ | PG archive tables not migrated |
| `integration.get_transaction_updates` | QUERY | 99585 rows | 99585 rows | ✓ |  |

## Schema: Website

| Function | Category | MSSQL Result | PG Result | Match | Notes |
|---|---|---|---|:---:|---|
| `website.activate_website_logon` | AUTH | raised exception (expected) | raised exception (expected) | ✓ |  |
| `website.calculate_customer_price` | SCALAR | price=25.00 | price=25.00 | ✓ |  |
| `website.change_password` | AUTH | raised exception (expected) | raised exception (expected) | ✓ |  |
| `website.insert_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | MSSQL uses TVP; PG-only test |
| `website.invoice_customer_orders` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | MSSQL uses TVP; PG-only test (created+picked+invoiced in txn) |
| `website.record_cold_room_temperatures` | COMPLEX | SKIP (TVP — not callable via pymssql) | executed OK | ✓ | MSSQL uses TVP; PG-only test |
| `website.record_vehicle_temperature` | COMPLEX | executed OK | executed OK | ✓ |  |
| `website.search_for_customers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ |  |
| `website.search_for_people` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ |  |
| `website.search_for_stock_items` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ |  |
| `website.search_for_stock_items_by_tags` | QUERY | 1 row(s) JSON (10 items) | 10 rows | ✓ |  |
| `website.search_for_suppliers` | QUERY | 2 row(s) JSON (10 items) | 10 rows | ✓ |  |
