# Conversion summary: Integration.GetOrderUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetOrderUpdates.sql`
- **Pattern:** Search / Query
- **Output:** `postgres/Integration/Functions/get_order_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_order_updates(
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
- `[Description]` square brackets stripped — not a reserved word in PostgreSQL
- Column aliases with spaces preserved via double-quoting in RETURNS TABLE declaration
- `ROUND()` unchanged — operates on numeric values
- `CASE WHEN ol.LastEditedWhen > o.LastEditedWhen ...` preserved verbatim in SELECT and WHERE
- Schema/table names lowercased: `Sales.Orders` → `sales.orders`, `Sales.OrderLines` → `sales.orderlines`, etc.
- `Total Excluding Tax`, `Tax Amount`, `Total Including Tax` typed as `numeric` (computed ROUND results)

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `warehouse.packagetypes` | `postgres/Warehouse/Tables/PackageTypes.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
