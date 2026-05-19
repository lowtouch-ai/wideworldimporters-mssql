# Conversion summary: WebApi.Cities

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/Cities.sql`
- **Output:** `postgres/WebApi/Views/cities.sql`

## Conversions applied
- `[WebApi].[Cities]` → `webapi.cities`
- `Application.Cities` → `application.cities`
- `Application.StateProvinces` → `application.state_provinces`
- `INNER JOIN` → `JOIN`
- `c.Location.Long` → `ST_X(c.Location::geometry)`
- `c.Location.Lat` → `ST_Y(c.Location::geometry)`
- `JSON_QUERY(... FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)` → `json_build_object(...)` (best-effort GeoJSON)
- `CONCAT('[', ..., ']')` coordinates array → `json_build_array(...)`

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH output` — the GeoJSON Feature object is a best-effort conversion; verify the `Location` field JSON structure matches what the original MSSQL view produced.

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` | ✓ converted |
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` | ✓ converted |

## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
