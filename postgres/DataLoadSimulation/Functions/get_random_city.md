# Conversion summary: DataLoadSimulation.GetRandomCity

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCity.sql`
- **Pattern:** Multi-value OUTPUT parameters → RETURNS TABLE(city_id, city_name, state_province_code, state_province_name, area_code)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_city.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_city()
RETURNS TABLE(city_id integer, city_name varchar(50), state_province_code varchar(5), state_province_name varchar(50), area_code varchar(4))
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CityID INT OUTPUT` | `city_id` | integer | TABLE column |
| `@CityName NVARCHAR(50) OUTPUT` | `city_name` | varchar(50) | TABLE column |
| `@StateProvinceCode NVARCHAR(5) OUTPUT` | `state_province_code` | varchar(5) | TABLE column |
| `@StateProvinceName NVARCHAR(50) OUTPUT` | `state_province_name` | varchar(50) | TABLE column |
| `@AreaCode NVARCHAR(4) OUTPUT` | `area_code` | varchar(4) | TABLE column |

## Conversion notes
- `WHILE @CityID IS NULL` retry loop → `LOOP ... EXIT WHEN v_city_id IS NOT NULL`
- `SELECT TOP 1 ... ORDER BY NEWID()` → `ORDER BY random() LIMIT 1`
- Uses `RETURN NEXT` pattern for single-row TABLE return

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
| `dataloadsimulation.areacode` | `postgres/DataLoadSimulation/Tables/AreaCode.sql` |
