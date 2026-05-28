# Conversion summary: WebApi.UpdateCountryFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCountryFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_country_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_country_from_json(p_country text, p_country_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Country nvarchar(MAX)` | `p_country text` | text | JSON object payload (9 fields) |
| `@CountryID int` | `p_country_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- All fields direct assignment (no ISNULL in source — caller must supply all required fields)
- `jsonb_to_record` with 9 typed columns

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.countries` | `postgres/Application/Tables/Countries.sql` |
