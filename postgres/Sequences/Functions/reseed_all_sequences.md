# Conversion summary: Sequences.ReseedAllSequences

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedAllSequences.sql`
- **Pattern:** Simple DML / void utility — no result set
- **Output:** `postgres/Sequences/Functions/reseed_all_sequences.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION sequences.reseed_all_sequences() RETURNS void
```

## Parameter mapping
No parameters (none in source SP).

## Conversion notes
- `EXEC Sequences.ReseedSequenceBeyondTableValues ...` → `PERFORM sequences.reseed_sequence_beyond_table_values(...)` (28 calls)
- All MSSQL sequence names (`'BuyingGroupID'` etc.) mapped to PostgreSQL names (`'buying_group_id_seq'`)
- All schema names lowercased (`Application` → `application`, `Sales` → `sales`, etc.)
- All table names mapped to the exact name used in the converted PostgreSQL DDL files (e.g., `BuyingGroups` → `buying_groups`, `InvoiceLines` → `invoicelines`)
- Column names preserve original casing (`BuyingGroupID`, `SupplierTransactionID`, etc.) — quoted by `%I` in the child function
- `SET NOCOUNT ON` removed

## TODOs
None — all 28 sequence/table pairs fully resolved against converted PostgreSQL files.

## Dependency
Requires `sequences.reseed_sequence_beyond_table_values` — defined in `postgres/Sequences/Functions/reseed_sequence_beyond_table_values.sql`.

## Tables referenced (28 combinations, 26 distinct sequences)
| MSSQL call | PG sequence | PG schema.table |
|---|---|---|
| BuyingGroupID / Sales.BuyingGroups | `buying_group_id_seq` | `sales.buying_groups` |
| CityID / Application.Cities | `city_id_seq` | `application.cities` |
| ColorID / Warehouse.Colors | `color_id_seq` | `warehouse.colors` |
| CountryID / Application.Countries | `country_id_seq` | `application.countries` |
| CustomerCategoryID / Sales.CustomerCategories | `customer_category_id_seq` | `sales.customer_categories` |
| CustomerID / Sales.Customers | `customer_id_seq` | `sales.customers` |
| DeliveryMethodID / Application.DeliveryMethods | `delivery_method_id_seq` | `application.delivery_methods` |
| InvoiceID / Sales.Invoices | `invoice_id_seq` | `sales.invoices` |
| InvoiceLineID / Sales.InvoiceLines | `invoice_line_id_seq` | `sales.invoicelines` |
| OrderID / Sales.Orders | `order_id_seq` | `sales.orders` |
| OrderLineID / Sales.OrderLines | `order_line_id_seq` | `sales.orderlines` |
| PackageTypeID / Warehouse.PackageTypes | `package_type_id_seq` | `warehouse.package_types` |
| PaymentMethodID / Application.PaymentMethods | `payment_method_id_seq` | `application.payment_methods` |
| PersonID / Application.People | `person_id_seq` | `application.people` |
| PurchaseOrderID / Purchasing.PurchaseOrders | `purchase_order_id_seq` | `purchasing.purchaseorders` |
| PurchaseOrderLineID / Purchasing.PurchaseOrderLines | `purchase_order_line_id_seq` | `purchasing.purchaseorderlines` |
| SpecialDealID / Sales.SpecialDeals | `special_deal_id_seq` | `sales.specialdeals` |
| StateProvinceID / Application.StateProvinces | `state_province_id_seq` | `application.state_provinces` |
| StockGroupID / Warehouse.StockGroups | `stock_group_id_seq` | `warehouse.stock_groups` |
| StockItemID / Warehouse.StockItems | `stock_item_id_seq` | `warehouse.stockitems` |
| StockItemStockGroupID / Warehouse.StockItemStockGroups | `stock_item_stock_group_id_seq` | `warehouse.stockitemstockgroups` |
| SupplierCategoryID / Purchasing.SupplierCategories | `supplier_category_id_seq` | `purchasing.supplier_categories` |
| SupplierID / Purchasing.Suppliers | `supplier_id_seq` | `purchasing.suppliers` |
| SystemParameterID / Application.SystemParameters | `system_parameter_id_seq` | `application.system_parameters` |
| TransactionID / Purchasing.SupplierTransactions | `transaction_id_seq` | `purchasing.suppliertransactions` |
| TransactionID / Sales.CustomerTransactions | `transaction_id_seq` | `sales.customertransactions` |
| TransactionID / Warehouse.StockItemTransactions | `transaction_id_seq` | `warehouse.stockitemtransactions` |
| TransactionTypeID / Application.TransactionTypes | `transaction_type_id_seq` | `application.transaction_types` |
