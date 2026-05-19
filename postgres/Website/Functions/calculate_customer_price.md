# calculate_customer_price

Converted from: `wwi-ssdt/wwi-ssdt/Website/Functions/CalculateCustomerPrice.sql`

## Summary

Scalar function that calculates the best (lowest) price for a given customer, stock item, and pricing date by evaluating special deals (unit price overrides, discount amounts, and discount percentages).

## Conversion notes

- `WITH EXECUTE AS OWNER` removed
- `DECLARE @var` → `_var` local variables in DECLARE block
- `SET @var = expr` → `_var := expr`
- `SELECT @var = col FROM tbl` → `SELECT col INTO _var FROM tbl`
- `RETURNS decimal(18,2)` → `RETURNS numeric(18,2)`
- Schema + table references lowercased: `Sales.Customers` → `sales.customers`, `Warehouse.StockItems` → `warehouse.stockitems`, etc.

## Dependencies

| Object | Status |
|---|---|
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
| `sales.specialdeals` | check postgres/Sales/Tables/SpecialDeals.sql |
| `warehouse.stockitemstockgroups` | check postgres/Warehouse/Tables/StockItemStockGroups.sql |
