# get_movement_updates

Converted from: `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetMovementUpdates.sql`

## Summary

Returns stock item transaction (movement) records modified within the cutoff window for DW incremental loads. Straightforward SELECT — no temporal tables or cursors.

## Conversion notes

- Simple SP with a single SELECT; converted to `RETURNS TABLE` + `RETURN QUERY`
- `datetime2(7)` → `timestamp(6)`
- Schema references lowercased

## Dependencies

| Object | Status |
|---|---|
| `warehouse.stockitemtransactions` | check postgres/Warehouse/Tables/StockItemTransactions.sql |
