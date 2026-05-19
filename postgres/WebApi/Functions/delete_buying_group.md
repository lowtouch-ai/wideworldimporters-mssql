# Conversion summary: WebApi.DeleteBuyingGroup

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteBuyingGroup.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_buying_group.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_buying_group(p_buying_group_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroupID int` | `p_buying_group_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteBuyingGroup]` → `webapi.delete_buying_group`
- `WITH EXECUTE AS OWNER` removed
- `@BuyingGroupID` → `p_buying_group_id`
- `Sales.BuyingGroups` → `sales.buying_groups`
- `AS BEGIN...END` → `AS $$ BEGIN...END; $$ LANGUAGE plpgsql`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` |
