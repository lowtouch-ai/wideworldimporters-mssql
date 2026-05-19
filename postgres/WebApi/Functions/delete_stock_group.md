# Conversion summary: WebApi.DeleteStockGroup

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockGroup.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_stock_group.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_stock_group(p_stock_group_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockGroupID int` | `p_stock_group_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteStockGroup]` → `webapi.delete_stock_group`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
