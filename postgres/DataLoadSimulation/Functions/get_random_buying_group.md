# Conversion summary: DataLoadSimulation.GetRandomBuyingGroup

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroup.sql`
- **Pattern:** Multi-value OUTPUT parameters → RETURNS TABLE(buying_group_id, buying_group_name)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_buying_group.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_buying_group()
RETURNS TABLE(buying_group_id integer, buying_group_name varchar(50))
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroupID INT OUTPUT` | `buying_group_id` | integer | TABLE column |
| `@BuyingGroupName NVARCHAR(50) OUTPUT` | `buying_group_name` | varchar(50) | TABLE column |

## Conversion notes
- `SELECT TOP 1 ... ORDER BY NEWID()` → `ORDER BY random() LIMIT 1`
- `ValidTo = '9999-12-31 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.buyinggroups` | `postgres/Sales/Tables/BuyingGroups.sql` |
