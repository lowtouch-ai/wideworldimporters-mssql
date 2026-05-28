# Conversion summary: Integration.GetMovementUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetMovementUpdates.sql`
- **Pattern:** Search / Query
- **Output:** `postgres/Integration/Functions/get_movement_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_movement_updates(
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
- `CAST(Quantity AS int)` → `CAST(Quantity AS integer)`
- `RETURN 0` removed (void-style return in TABLE-returning function)
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` / `WITH EXECUTE AS OWNER` removed
- Column aliases with spaces preserved via double-quoting in RETURNS TABLE declaration
- Schema/table lowercased: `Warehouse.StockItemTransactions` → `warehouse.stockitemtransactions`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitemtransactions` | `postgres/Warehouse/Tables/StockItemTransactions.sql` |
