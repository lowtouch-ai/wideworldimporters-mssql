# Conversion summary: WebApi.UpdateCityFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCityFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_city_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_city_from_json(p_city text, p_city_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@City nvarchar(MAX)` | `p_city text` | text | JSON object payload |
| `@CityID int` | `p_city_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- All fields direct assignment (no ISNULL in source)
- `location` (geography) not in SET clause — omitted

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
