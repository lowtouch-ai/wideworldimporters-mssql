# search_for_stock_items

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItems.sql`

## Summary

Returns stock items whose `SearchDetails` field matches the search text.

## Conversion notes

- `SELECT TOP(@n) ... FOR JSON AUTO, ROOT('StockItems')` → `RETURNS TABLE(...) ... LIMIT`
- `LIKE` → `ILIKE` (case-insensitive)

## Dependencies

| Object | Status |
|---|---|
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
