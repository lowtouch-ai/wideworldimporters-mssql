# Conversion summary: WebApi.DeleteStockItem

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockItem.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_stock_item.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_stock_item(p_stock_item_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockItemID int` | `p_stock_item_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteStockItem]` → `webapi.delete_stock_item`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
