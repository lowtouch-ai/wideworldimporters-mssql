# Conversion summary: WebApi.UpdateBuyingGroupFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateBuyingGroupFromJson.sql`
- **Pattern:** Update from JSON (single-record partial update)
- **Output:** `postgres/WebApi/Functions/update_buying_group_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_buying_group_from_json(p_buying_group text, p_buying_group_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroup nvarchar(MAX)` | `p_buying_group text` | text | JSON object payload |
| `@BuyingGroupID int` | `p_buying_group_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON(@BuyingGroup) WITH (...) as json` → `jsonb_to_record(p_buying_group::jsonb) AS x(...)`
- All fields direct assignment (no ISNULL in source)
- `WHERE Sales.BuyingGroups.BuyingGroupID = @BuyingGroupID` → `WHERE buying_groups.buyinggroupid = p_buying_group_id`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` |
