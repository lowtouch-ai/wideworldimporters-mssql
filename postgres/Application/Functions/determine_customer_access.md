# Conversion summary: Application.DetermineCustomerAccess

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/Application/Functions/DetermineCustomerAccess.sql`
- **Pattern:** Inline Table-Valued Function (ITVF) / Row Level Security predicate
- **Output:** `postgres/Application/Functions/determine_customer_access.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.determine_customer_access(
    p_city_id integer
) RETURNS TABLE(AccessResult integer) LANGUAGE plpgsql STABLE SECURITY DEFINER;
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CityID int` | `p_city_id integer` | integer | City to check access against |

## Conversion notes
- `[Application].DetermineCustomerAccess` → `application.determine_customer_access`
- `RETURNS TABLE` inline TVF → `RETURNS TABLE(AccessResult integer)` with `RETURN QUERY`
- `WITH SCHEMABINDING` → removed (no PostgreSQL equivalent)
- `IS_ROLEMEMBER(N'db_owner')` → `pg_has_role(current_user, 'db_owner', 'member')`
- `IS_ROLEMEMBER(territory + N' Sales')` → `pg_has_role(current_user, v_sales_territory || ' Sales', 'member')` with NULL guard
- `ORIGINAL_LOGIN()` → `current_user` (PostgreSQL has no distinction between original and impersonated login)
- `SESSION_CONTEXT(N'SalesTerritory')` → `current_setting('app.SalesTerritory', true)` (second arg `true` returns NULL instead of throwing if unset)
- Subquery for SalesTerritory lookup extracted into `v_sales_territory` variable to avoid duplication
- `STABLE SECURITY DEFINER` added: `STABLE` because it only reads tables; `SECURITY DEFINER` preserves RLS predicate behaviour consistent with the original `ORIGINAL_LOGIN()` intent
- `[Application].[Cities]` → `application.cities`
- `[Application].[StateProvinces]` → `application.stateprovinces`

## TODOs
- `pg_has_role` throws `ERROR: role "X Sales" does not exist` if the role is absent. If territory roles are not guaranteed to exist, add a pre-check against `pg_roles` or wrap the call in an `EXCEPTION WHEN` block.
- `current_user` replaces `ORIGINAL_LOGIN()` — in MSSQL these differ when impersonation (`EXECUTE AS`) is active. PostgreSQL has no direct equivalent; review if `session_user` is more appropriate in your auth model.
- `current_setting('app.SalesTerritory', true)` must be set per-session by the application before calling this function (e.g. `SET app.SalesTerritory = 'Midwest';`).

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` ✓ converted |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` ✓ converted |
