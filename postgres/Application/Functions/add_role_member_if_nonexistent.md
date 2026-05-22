# Conversion summary: Application.AddRoleMemberIfNonexistent

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/AddRoleMemberIfNonexistent.sql`
- **Pattern:** Simple DML / void utility — no result set
- **Output:** `postgres/Application/Functions/add_role_member_if_nonexistent.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.add_role_member_if_nonexistent(
    p_role_name text,
    p_user_name text
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@RoleName sysname` | `p_role_name text` | `text` | `sysname` → `text` |
| `@UserName sysname` | `p_user_name text` | `text` | |

## Conversion notes
- `sys.database_role_members` + `sys.database_principals` three-way join → `pg_auth_members` + `pg_roles` two-way join (simpler — no need to filter by type since `pg_auth_members` only stores role-to-role grants)
- `ALTER ROLE ... ADD MEMBER ...` → `GRANT role TO user` (standard SQL; PostgreSQL's equivalent)
- `EXECUTE N'ALTER ROLE ' + QUOTENAME(...) + ' ADD MEMBER ' + QUOTENAME(...)` → `EXECUTE format('GRANT %I TO %I', ...)` — `%I` replaces `QUOTENAME`
- `WITH EXECUTE AS OWNER` removed
- `BEGIN TRY / BEGIN CATCH / THROW` → `BEGIN / EXCEPTION WHEN OTHERS THEN / RAISE`
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` removed

## TODOs
None.

## System objects referenced
| Object | Notes |
|---|---|
| `pg_auth_members` | Replaces `sys.database_role_members` |
| `pg_roles` | Replaces `sys.database_principals WHERE type = 'R'/'S'` |
