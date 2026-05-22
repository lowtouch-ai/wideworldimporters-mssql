# Conversion summary: Application.CreateRoleIfNonexistent

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/CreateRoleIfNonexistent.sql`
- **Pattern:** Simple DML / void utility — no result set
- **Output:** `postgres/Application/Functions/create_role_if_nonexistent.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.create_role_if_nonexistent(p_role_name text) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@RoleName sysname` | `p_role_name text` | `text` | `sysname` → `text` |

## Conversion notes
- `sys.database_principals WHERE type = N'R'` → `pg_roles` (PostgreSQL system catalog)
- `EXECUTE N'CREATE ROLE ' + QUOTENAME(@RoleName)` → `EXECUTE format('CREATE ROLE %I', p_role_name)` — `%I` replaces `QUOTENAME`
- `WITH EXECUTE AS OWNER` removed (no PG equivalent needed)
- `BEGIN TRY / BEGIN CATCH` → `BEGIN / EXCEPTION WHEN OTHERS THEN`
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `THROW` (re-raise) → `RAISE` (bare)
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` removed
- Note: PostgreSQL does not support `CREATE ROLE IF NOT EXISTS`; the existence check via `pg_roles` is required

## TODOs
None.

## System objects referenced
| Object | Notes |
|---|---|
| `pg_roles` | Replaces `sys.database_principals WHERE type = 'R'` |
