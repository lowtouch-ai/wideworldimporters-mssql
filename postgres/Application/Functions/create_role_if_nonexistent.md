# Conversion summary: Application.CreateRoleIfNonexistent

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/CreateRoleIfNonexistent.sql`
- **Pattern:** Simple DML / admin utility — void return
- **Output:** `postgres/Application/Functions/create_role_if_nonexistent.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.create_role_if_nonexistent(p_role_name text) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@RoleName sysname` | `p_role_name text` | text | sysname maps to text in PG |

## Conversion notes
- `WITH EXECUTE AS OWNER` → `SECURITY DEFINER` (equivalent: function runs as its owner)
- `sys.database_principals WHERE type = 'R'` → `pg_roles WHERE rolname = ...`
- `EXECUTE(@SQL)` with `QUOTENAME(@RoleName)` → `EXECUTE format('CREATE ROLE %I', p_role_name)` (`%I` applies identifier quoting)
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `BEGIN TRY/CATCH + THROW` → `BEGIN/EXCEPTION WHEN OTHERS THEN RAISE`
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` → removed

## TODOs
- None — clean conversion.

## Tables referenced
None (reads `pg_roles` catalog only).
