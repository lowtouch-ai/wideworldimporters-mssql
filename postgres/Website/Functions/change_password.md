# Conversion summary: Website.ChangePassword

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ChangePassword.sql`
- **Pattern:** Simple DML → `RETURNS void`
- **Output:** `postgres/Website/Functions/change_password.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.change_password(
    p_person_id integer,
    p_old_password varchar(40),
    p_new_password varchar(40)
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PersonID int` | `p_person_id integer` | integer | |
| `@OldPassword nvarchar(40)` | `p_old_password varchar(40)` | varchar(40) | |
| `@NewPassword nvarchar(40)` | `p_new_password varchar(40)` | varchar(40) | |

## Conversion notes
- `HASHBYTES(N'SHA2_256', @NewPassword + FullName)` → `digest((p_new_password || fullname)::bytea, 'sha256')` via pgcrypto
- Old password validated in WHERE: `hashedpassword = digest((p_old_password || fullname)::bytea, 'sha256')`
- `@@ROWCOUNT` → `GET DIAGNOSTICS v_rowcount = ROW_COUNT`
- `IsPermittedToLogon = 1` → `ispermittedtologon = true`
- `THROW 51000, N'...', 1` → `RAISE EXCEPTION '...'`
- `PRINT N'...'` → `RAISE NOTICE '...'`
- `RETURN -1` removed (void function)
- `SET NOCOUNT ON`, `SET XACT_ABORT ON`, `WITH EXECUTE AS OWNER` removed

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
