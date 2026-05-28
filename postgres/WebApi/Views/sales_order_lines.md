# Conversion summary: WebApi.SalesOrderLines

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrderLines.sql`
- **Output:** `postgres/WebApi/Views/sales_order_lines.sql`

## Conversions applied
- `[WebApi].[SalesOrderLines]` → `webapi.sales_order_lines`
- `INNER JOIN` → `JOIN` (3 occurrences)
- Column alias `ProductName = si.StockItemName` → `si.StockItemName AS ProductName`
- `Sales.OrderLines` → `sales.orderlines`
- `Warehouse.StockItems` → `warehouse.stockitems`
- `Warehouse.Colors` → `warehouse.colors`
- `Warehouse.PackageTypes` → `warehouse.package_types`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` | ✓ converted |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` | ✓ converted |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` | ✓ converted |
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` | ✓ converted |
