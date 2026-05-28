# Conversion summary: WebApi.Login

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/Login.sql`
- **Pattern:** Search / Query (SELECT returning result set)
- **Output:** `postgres/WebApi/Functions/login.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.login(
    p_logon_name varchar(256),
    p_password varchar(256)
) RETURNS TABLE(PersonID integer, PreferredName varchar(50), IsSalesperson boolean, IsEmployee boolean, Territory text)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LogonName nvarchar(256)` | `p_logon_name varchar(256)` | varchar(256) | Login identifier |
| `@Password nvarchar(256)` | `p_password varchar(256)` | varchar(256) | Accepted but not validated (see TODOs) |

## Conversion notes
- `[WebApi].[Login]` → `webapi.login`
- `WITH EXECUTE AS OWNER` removed
- Column alias `Territory = JSON_VALUE(CustomFields,'$.PrimarySalesTerritory')` → `(p.CustomFields::jsonb)->>'PrimarySalesTerritory' AS Territory`
- `JSON_VALUE(CustomFields,'$.PrimarySalesTerritory')` → `(CustomFields::jsonb)->>'PrimarySalesTerritory'` (CustomFields is TEXT; cast to jsonb for extraction)
- `IsPermittedToLogon = 1` → `IsPermittedToLogon = TRUE` (BIT → BOOLEAN)
- `Application.People` → `application.people`
- `SELECT` → `RETURN QUERY SELECT`

## TODOs
- Password validation was commented out in the original SP (`--and HashedPassword = HASHBYTES(N'SHA2_256', @Password)`). The `p_password` parameter is accepted but not used. Implement password hashing validation using `digest(p_password, 'sha256')` from pgcrypto when ready.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
