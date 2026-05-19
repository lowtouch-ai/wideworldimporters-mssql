# Conversion summary: WebApi.InsertStockGroupsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockGroupsFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_stock_groups_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_stock_groups_from_json(p_stock_groups text, p_user_id integer) RETURNS TABLE(stockgroupid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockGroups nvarchar(MAX)` | `p_stock_groups text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.StockGroupID → RETURNING stock_groups.stockgroupid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stock_groups` | `postgres/Warehouse/Tables/StockGroups.sql` |
