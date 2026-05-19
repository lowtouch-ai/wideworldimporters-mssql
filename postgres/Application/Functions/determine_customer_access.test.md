# pgfunc-test report: Application.determine_customer_access

## Source
- **Function file:** `postgres/Application/Functions/determine_customer_access.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.cities` | ✓ Already applied | `postgres/Application/Tables/Cities.sql` |
| `application.stateprovinces` | ✓ Already applied | `postgres/Application/Tables/StateProvinces.sql` |

## Extensions
| Extension | Status |
|---|---|
| `pgcrypto` | ✓ Already exists |

## Result
- Function load (initial): ✗ Failed — `pg_has_role` throws on non-existent roles (unlike MSSQL `IS_ROLEMEMBER` which returns NULL)
- Fix applied: pre-guard all `pg_has_role` calls with `EXISTS (SELECT 1 FROM pg_roles WHERE rolname = ...)`
- Function load (fixed): ✓ Success
- Test call: `SELECT * FROM application.determine_customer_access(1) LIMIT 5;`
- Result: 0 rows (correct — no `db_owner` or territory roles exist in test DB)

## TODOs
- `pg_has_role` now guarded with `pg_roles` existence check — safe for any role set.
- `current_user` replaces `ORIGINAL_LOGIN()` — review if `session_user` is more appropriate when connection pooling is in use.
- `current_setting('app.SalesTerritory', true)` must be set per-session by the application before calling this function.

## Next steps
- Convert Application stored procedures: `/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/Application/Stored Procedures/AddRoleMemberIfNonexistent.sql"`
