# Conversion summary: WebApi.InsertCountriesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCountriesFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_countries_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_countries_from_json(p_countries text, p_user_id integer) RETURNS TABLE(countryid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Countries nvarchar(MAX)` | `p_countries text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- Required fields (N'strict $.X'): CountryName, FormalName, Continent, Region, Subregion — no strict equivalent in PG; NULL will cause NOT NULL violation naturally
- `OUTPUT inserted.CountryID` → `RETURNING countries.countryid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.countries` | `postgres/Application/Tables/Countries.sql` |
