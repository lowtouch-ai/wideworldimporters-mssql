# Conversion summary: WebApi.StockItems

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/StockItems.sql`
- **Output:** `postgres/WebApi/Views/stock_items.sql`

## Conversions applied
- `[WebApi].[StockItems]` → `webapi.stock_items`
- `INNER JOIN` → `JOIN` (5 occurrences)
- `Warehouse.StockItems` → `warehouse.stockitems`
- `Warehouse.StockItemHoldings` → `warehouse.stockitemholdings`
- `Purchasing.Suppliers` → `purchasing.suppliers`
- `Warehouse.Colors` → `warehouse.colors`
- `Warehouse.PackageTypes` → `warehouse.package_types`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` | ✓ converted |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` | ✓ converted |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` | ✓ converted |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` | ✓ converted |
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` | ✓ converted |
