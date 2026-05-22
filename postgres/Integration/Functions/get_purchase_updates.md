# Conversion summary: Integration.GetPurchaseUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPurchaseUpdates.sql`
- **Pattern:** Search / Query
- **Output:** `postgres/Integration/Functions/get_purchase_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_purchase_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(...)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- `datetime2(7)` → `timestamp`
- `RETURN 0` removed (TABLE-returning function uses `RETURN QUERY`)
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` / `WITH EXECUTE AS OWNER` removed
- `bit` column `IsOrderLineFinalized` → `boolean`
- `pol.OrderedOuters * si.QuantityPerOuter` → integer arithmetic unchanged
- `CASE WHEN pol.LastEditedWhen > po.LastEditedWhen ...` preserved verbatim in SELECT and WHERE
- Schema/table names lowercased throughout

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` |
| `purchasing.purchaseorderlines` | `postgres/Purchasing/Tables/PurchaseOrderLines.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
