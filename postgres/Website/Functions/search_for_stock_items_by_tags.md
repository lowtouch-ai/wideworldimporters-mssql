# search_for_stock_items_by_tags

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItemsByTags.sql`

## Summary

Returns stock items whose `Tags` field matches the search text.

## Conversion notes

- `SELECT TOP(@n) ... FOR JSON AUTO, ROOT('StockItems')` → `RETURNS TABLE(...) ... LIMIT`
- `LIKE` → `ILIKE`

## Dependencies

| Object | Status |
|---|---|
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
