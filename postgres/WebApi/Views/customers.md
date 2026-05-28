# Conversion summary: WebApi.Customers

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/Customers.sql`
- **Output:** `postgres/WebApi/Views/customers.sql`

## Conversions applied
- `[WebApi].[Customers]` → `webapi.customers`
- `LEFT OUTER JOIN` → `LEFT JOIN` (7 occurrences)
- Column alias `PostalCity = pc.CityName` → `pc.CityName AS PostalCity`
- `Column alias` `DeliveryLocation = JSON_QUERY(...)` → `json_build_object(...)` (best-effort GeoJSON)
- `c.DeliveryLocation.Long` → `ST_X(c.DeliveryLocation::geometry)`
- `c.DeliveryLocation.Lat` → `ST_Y(c.DeliveryLocation::geometry)`
- `CONCAT('[', ..., ']')` coordinates array → `json_build_array(...)`
- `[Application].People` → `application.people`
- `[Application].DeliveryMethods` → `application.delivery_methods`
- `[Application].Cities` → `application.cities`
- `[Application].StateProvinces` → `application.state_provinces`

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH output` — the `DeliveryLocation` GeoJSON Feature (including nested `properties` keys) is a best-effort conversion from MSSQL's `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` syntax.

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.cities` | `postgres/Application/Tables/Cities.sql` | ✓ converted |
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` | ✓ converted |

## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
