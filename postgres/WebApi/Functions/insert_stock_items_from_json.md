# Conversion summary: WebApi.InsertStockItemsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockItemsFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_stock_items_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_stock_items_from_json(p_stock_items text, p_user_id integer) RETURNS TABLE(stockitemid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockItems nvarchar(MAX)` | `p_stock_items text` | text | JSON array payload (20 fields) |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `varbinary(MAX)` (Photo) → accepted as `text` in JSON recordset, decoded via `decode(x."Photo", 'base64')::bytea`
- `nvarchar(MAX) AS JSON` (CustomFields) → `text` in recordset (table column is `text`)
- `bit` → `boolean` for IsChillerStock
- `OUTPUT inserted.StockItemID → RETURNING stockitems.stockitemid`

## TODOs
- Photo field: caller must supply base64-encoded binary string; function decodes with `decode(..., 'base64')`.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
