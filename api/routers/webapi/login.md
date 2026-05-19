# Conversion summary: WebApi.Login

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/Login.sql`
- **Pattern:** Auth / Password
- **HTTP:** POST `/web-api/login` → 200 / 401

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@LogonName nvarchar(256)` | Query param `logon_name: str` | str | Matched to `"LogonName"` column |
| `@Password nvarchar(256)` | Query param `password: str` | str | Not validated — see warnings |

## SQL construct conversions
- `JSON_VALUE(CustomFields,'$.PrimarySalesTerritory')` → `("CustomFields"::jsonb)->>'PrimarySalesTerritory'`
- `Territory = expr` (reversed alias) → `expr AS "Territory"`
- `IsPermittedToLogon = 1` → `"IsPermittedToLogon" = TRUE`
- `FROM Application.People` → `FROM application.people`
- Result row absent → `HTTPException(401, detail="Invalid credentials")`

## Warnings / manual review items
- The original SP has the password check commented out: `--and HashedPassword = HASHBYTES(N'SHA2_256', @Password)`. The endpoint accepts `password` as a parameter but does **not** validate it. Replace the query parameter with a proper auth dependency (e.g. OAuth2/JWT) before production use.
