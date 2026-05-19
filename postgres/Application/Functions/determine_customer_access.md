# Conversion summary: Application.DetermineCustomerAccess

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/Application/Functions/DetermineCustomerAccess.sql`
- **Pattern:** Inline table-valued function (TVF) → `RETURNS TABLE`
- **Output:** `postgres/Application/Functions/determine_customer_access.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.determine_customer_access(p_city_id integer)
RETURNS TABLE("AccessResult" integer)
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CityID int` | `p_city_id integer` | `integer` | |

## Conversion notes
- `CREATE FUNCTION ... RETURNS TABLE ... AS RETURN (SELECT ...)` → `RETURNS TABLE(...) ... RETURN QUERY SELECT ...`
- `WITH SCHEMABINDING` → removed (no PostgreSQL equivalent)
- `IS_ROLEMEMBER('db_owner')` → `pg_has_role(current_user, 'db_owner', 'MEMBER')`
- `IS_ROLEMEMBER(<role>)` → `pg_has_role(current_user, <role>, 'MEMBER')`
- `ORIGINAL_LOGIN()` → `session_user` (the session's original authenticated login, unaffected by `SET ROLE`)
- `SESSION_CONTEXT(N'SalesTerritory')` → `current_setting('app.SalesTerritory', true)` (returns NULL if unset)
- String concatenation `+` → `||`
- `[Application].Cities` → `application.cities`
- `[Application].StateProvinces` → `application.stateprovinces`

## TODOs
- `pg_has_role()` raises an error if the role name does not exist, whereas MSSQL's `IS_ROLEMEMBER()` returns NULL. Wrap with an EXCEPTION block or pre-check `pg_roles` if the sales territory role may not exist.
- `current_setting('app.SalesTerritory', true)` requires the session setting to be pre-set via `SET LOCAL "app.SalesTerritory" = '...'` by the calling layer (application or connection pool setup).

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
