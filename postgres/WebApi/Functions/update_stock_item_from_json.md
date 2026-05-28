# Conversion summary: WebApi.UpdateStockItemFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockItemFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_stock_item_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_stock_item_from_json(p_stock_item text, p_stock_item_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockItem nvarchar(MAX)` | `p_stock_item text` | text | JSON payload |
| `@StockItemID int` | `p_stock_item_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_stock_item::jsonb) AS json(…)` with 19 field aliases (snake_case)
- `ISNULL(json.X, tbl.X)` → `COALESCE(json.x, tbl."X")` throughout
- `varbinary(MAX)` (Photo) → `bytea`
- `nvarchar(MAX) AS JSON` (CustomFields) → `jsonb`
- `bit` (IsChillerStock) → `boolean`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
