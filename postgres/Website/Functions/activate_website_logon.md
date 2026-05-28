# Conversion summary: Website.ActivateWebsiteLogon

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/ActivateWebsiteLogon.sql`
- **Pattern:** Simple DML → `RETURNS void`
- **Output:** `postgres/Website/Functions/activate_website_logon.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.activate_website_logon(
    p_person_id integer,
    p_logon_name varchar(50),
    p_initial_password varchar(40)
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PersonID int` | `p_person_id integer` | integer | |
| `@LogonName nvarchar(50)` | `p_logon_name varchar(50)` | varchar(50) | |
| `@InitialPassword nvarchar(40)` | `p_initial_password varchar(40)` | varchar(40) | |

## Conversion notes
- `HASHBYTES(N'SHA2_256', @InitialPassword + FullName)` → `digest((p_initial_password || fullname)::bytea, 'sha256')` via pgcrypto
- `@@ROWCOUNT` → `GET DIAGNOSTICS v_rowcount = ROW_COUNT`
- `IsPermittedToLogon = 1` → `ispermittedtologon = true`
- `IsPermittedToLogon = 0` (WHERE) → `ispermittedtologon = false`
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
