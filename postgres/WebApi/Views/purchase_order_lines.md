# Conversion summary: WebApi.PurchaseOrderLines

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/PurchaseOrderLines.sql`
- **Output:** `postgres/WebApi/Views/purchase_order_lines.sql`

## Conversions applied
- `[WebApi].[PurchaseOrderLines]` → `webapi.purchase_order_lines`
- `INNER JOIN` → `JOIN` (3 occurrences)
- Column alias `ProductName = si.StockItemName` → `si.StockItemName AS ProductName`
- `Purchasing.PurchaseOrderLines` → `purchasing.purchaseorderlines`
- `Warehouse.StockItems` → `warehouse.stockitems`
- `Warehouse.Colors` → `warehouse.colors`
- `Warehouse.PackageTypes` → `warehouse.package_types`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `purchasing.purchaseorderlines` | `postgres/Purchasing/Tables/PurchaseOrderLines.sql` | ✓ converted |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` | ✓ converted |
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` | ✓ converted |
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` | ✓ converted |
