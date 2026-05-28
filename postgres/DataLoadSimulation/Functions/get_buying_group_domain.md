# Conversion summary: DataLoadSimulation.GetBuyingGroupDomain

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetBuyingGroupDomain.sql`
- **Pattern:** Multi-value OUTPUT parameters → RETURNS TABLE(web_domain, email_domain)
- **Output:** `postgres/DataLoadSimulation/Functions/get_buying_group_domain.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_buying_group_domain(p_buying_group varchar(50))
RETURNS TABLE(web_domain varchar(256), email_domain varchar(256))
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@BuyingGroup NVARCHAR(50)` | `p_buying_group varchar(50)` | varchar(50) | |
| `@WebDomain NVARCHAR(256) OUTPUT` | `web_domain` | varchar(256) | TABLE column |
| `@EmailDomain NVARCHAR(256) OUTPUT` | `email_domain` | varchar(256) | TABLE column |

## Conversion notes
- Table variable `@urls` with hard-coded VALUES → CTE with VALUES
- Default `'N/A'` values achieved via `UNION ALL WHERE NOT EXISTS` guard
- `SELECT @var = col FROM @tableVar WHERE ...` → `RETURN QUERY SELECT ... FROM cte WHERE ...`

## TODOs
None.

## Tables referenced
None (all data is inline VALUES).
