# get_stock_holding_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockHoldingUpdates.sql`

## Summary

Returns a full snapshot of current stock item holdings (no cutoff window — always returns all rows).

## Conversion notes

- No parameters in original; function signature has no parameters
- Straightforward SELECT; converted to `RETURNS TABLE` + `RETURN QUERY`

## Dependencies

| Object | Status |
|---|---|
| `warehouse.stockitemholdings` | check postgres/Warehouse/Tables/StockItemHoldings.sql |
