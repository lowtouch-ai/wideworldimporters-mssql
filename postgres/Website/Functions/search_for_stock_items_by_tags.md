# Conversion summary: Website.SearchForStockItemsByTags

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForStockItemsByTags.sql`
- **Pattern:** Search/Query → `RETURNS jsonb`
- **Output:** `postgres/Website/Functions/search_for_stock_items_by_tags.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.search_for_stock_items_by_tags(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SearchText nvarchar(1000)` | `p_search_text varchar(1000)` | varchar(1000) | |
| `@MaximumRowsToReturn int` | `p_maximum_rows_to_return integer` | integer | |

## Conversion notes
- `FOR JSON AUTO, ROOT(N'StockItems')` → `json_build_object('StockItems', json_agg(row_to_json(t)))`
- `TOP(@MaximumRowsToReturn)` → `LIMIT p_maximum_rows_to_return`
- `LIKE N'%' + @SearchText + N'%'` → `LIKE '%' || p_search_text || '%'` on Tags (text) column
- `WITH EXECUTE AS OWNER` removed

## TODOs
- Verify JSON shape matches original `FOR JSON AUTO, ROOT(N'StockItems')` output
- Tags column is stored as nvarchar in MSSQL; LIKE on text works in PostgreSQL but consider `@>` jsonb operator if Tags is structured JSON

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
