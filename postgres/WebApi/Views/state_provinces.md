# Conversion summary: WebApi.StateProvinces

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/StateProvinces.sql`
- **Output:** `postgres/WebApi/Views/state_provinces.sql`

## Conversions applied
- `[WebApi].[StateProvinces]` → `webapi.state_provinces`
- `INNER JOIN` → `JOIN` (1 occurrence)
- Column alias `Border = JSON_QUERY(...)` → `json_build_object(...)` using `ST_AsGeoJSON()` (replaces entire MSSQL REPLACE-chain WKT-to-GeoJSON conversion)
- `sp.Border.STGeometryType()` → handled implicitly by `ST_AsGeoJSON(sp.Border::geometry)` which outputs the correct GeoJSON geometry type
- `sp.Border.ToString()` → `ST_AsGeoJSON(sp.Border::geometry)` (full GeoJSON geometry, not just WKT)
- String concatenation `+` → not needed (ST_AsGeoJSON returns complete JSON)
- `Application.StateProvinces` → `application.state_provinces`
- `Application.Countries` → `application.countries`

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH output` — the original builds GeoJSON Feature via string concatenation and REPLACE chains. The PostgreSQL version uses `ST_AsGeoJSON()` which returns standard GeoJSON geometry; the outer Feature wrapper is added via `json_build_object`. Verify the `Border` field structure matches what downstream consumers expect.

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` | ✓ converted |
| `application.countries` | `postgres/Application/Tables/Countries.sql` | ✓ converted |

## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
