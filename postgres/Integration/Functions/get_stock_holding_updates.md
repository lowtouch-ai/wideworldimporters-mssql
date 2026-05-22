# Conversion summary: Integration.GetStockHoldingUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockHoldingUpdates.sql`
- **Pattern:** Static snapshot / Search Query
- **Output:** `postgres/Integration/Functions/get_stock_holding_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_stock_holding_updates() RETURNS TABLE(...)
```

## Parameter mapping
_(no parameters)_

## Conversion notes
- No parameters — parameterless function
- `RETURN 0` removed (TABLE-returning function uses `RETURN QUERY`)
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` / `WITH EXECUTE AS OWNER` removed
- Column aliases with spaces preserved via double-quoting in RETURNS TABLE declaration
- `Warehouse.StockItemHoldings` → `warehouse.stockitemholdings`
- Column types inferred from converted table DDL: QuantityOnHand/LastStocktakeQuantity/ReorderLevel/TargetStockLevel/StockItemID → `integer`, BinLocation → `varchar(20)`, LastCostPrice → `numeric(18,2)`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
