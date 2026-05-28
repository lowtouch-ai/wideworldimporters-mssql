# Conversion summary: DataLoadSimulation.GetCityLocation

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCityLocation.sql`
- **Pattern:** Scalar function → `RETURNS geography`
- **Output:** `postgres/DataLoadSimulation/Functions/get_city_location.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_city_location(p_city_id integer) RETURNS geography
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@CityID INT` | `p_city_id integer` | `integer` |

## Conversion notes
- `RETURNS GEOGRAPHY` → `RETURNS geography` (PostGIS)
- `SELECT TOP 1 @Loc = [Location] FROM Application.Cities WHERE CityID = @CityID` → `SELECT "Location" INTO _loc FROM application.cities WHERE "CityID" = p_city_id LIMIT 1`
- `DECLARE @Loc AS GEOGRAPHY` → `_loc geography` in DECLARE block

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |

**Requires:** `CREATE EXTENSION IF NOT EXISTS postgis;`
