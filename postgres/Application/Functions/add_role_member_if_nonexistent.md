# Conversion summary: Application.AddRoleMemberIfNonexistent

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/AddRoleMemberIfNonexistent.sql`
- **Pattern:** Simple DML / admin utility — void return
- **Output:** `postgres/Application/Functions/add_role_member_if_nonexistent.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.add_role_member_if_nonexistent(p_role_name text, p_user_name text) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@RoleName sysname` | `p_role_name text` | text | |
| `@UserName sysname` | `p_user_name text` | text | |

## Conversion notes
- `WITH EXECUTE AS OWNER` → `SECURITY DEFINER`
- `sys.database_role_members + sys.database_principals` join → `pg_auth_members + pg_roles` catalog join
- `ALTER ROLE ... ADD MEMBER` → `GRANT %I TO %I` via `EXECUTE format(...)`
- `QUOTENAME(@RoleName)` → `%I` in format string (identifier quoting)
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `BEGIN TRY/CATCH + THROW` → `BEGIN/EXCEPTION WHEN OTHERS THEN RAISE`

## TODOs
- None — clean conversion.

## Tables referenced
None (reads `pg_auth_members` / `pg_roles` catalogs only).
