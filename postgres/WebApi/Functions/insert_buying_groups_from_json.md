# Conversion summary: WebApi.InsertBuyingGroupsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertBuyingGroupsFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_buying_groups_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_buying_groups_from_json(p_buying_groups text, p_user_id integer) RETURNS TABLE(BuyingGroupID integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroups nvarchar(MAX)` | `p_buying_groups text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON(@BuyingGroups) WITH (BuyingGroupName nvarchar(50))` → `jsonb_to_recordset(p_buying_groups::jsonb) AS x("BuyingGroupName" varchar(50))`
- `OUTPUT inserted.BuyingGroupID` → `RETURNING "BuyingGroupID"` inside `RETURN QUERY INSERT ... RETURNING`
- `LastEditedBy = @UserID` → `p_user_id` appended as scalar in SELECT list
- `WITH EXECUTE AS OWNER` removed

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` |
