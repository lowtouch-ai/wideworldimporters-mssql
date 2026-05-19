# Conversion summary: WebApi.InsertCitiesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCitiesFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_cities_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_cities_from_json(p_cities text, p_user_id integer) RETURNS TABLE(cityid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Cities nvarchar(MAX)` | `p_cities text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON ... WITH (CityName nvarchar(50) N'strict $.CityName', ...)` → `jsonb_to_recordset(p_cities::jsonb) AS x("CityName" varchar(50), ...)`
- `OUTPUT inserted.CityID` → `RETURNING cities.cityid` (table-qualified to avoid RETURNS TABLE ambiguity)
- `location` (geography column in application.cities) not present in original SP — omitted

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
