# Conversion summary: WebApi.UpdateStockGroupFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockGroupFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_stock_group_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_stock_group_from_json(p_stock_group text, p_stock_group_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StockGroup nvarchar(MAX)` | `p_stock_group text` | text | JSON payload |
| `@StockGroupID int` | `p_stock_group_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_stock_group::jsonb) AS json(…)`
- Column names preserved with double-quotes in the UPDATE SET clause

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockgroups` | `postgres/Warehouse/Tables/StockGroups.sql` |
