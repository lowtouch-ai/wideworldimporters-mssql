# Conversion summary: WebApi.Suppliers

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/Suppliers.sql`
- **Output:** `postgres/WebApi/Views/suppliers.sql`

## Conversions applied
- `[WebApi].[Suppliers]` → `webapi.suppliers`
- `LEFT OUTER JOIN` → `LEFT JOIN` (6 occurrences)
- Column alias `DeliveryLocation = JSON_QUERY(...)` → `json_build_object(...)` (best-effort GeoJSON)
- `s.DeliveryLocation.Long` → `ST_X(s.DeliveryLocation::geometry)`
- `s.DeliveryLocation.Lat` → `ST_Y(s.DeliveryLocation::geometry)`
- `CONCAT('[', ..., ']')` coordinates array → `json_build_array(...)`
- `Purchasing.Suppliers` → `purchasing.suppliers`
- `Purchasing.SupplierCategories` → `purchasing.supplier_categories`
- `[Application].People` → `application.people`
- `[Application].DeliveryMethods` → `application.delivery_methods`
- `[Application].Cities` → `application.cities`
- `[Application].StateProvinces` → `application.state_provinces`

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH output` — the `DeliveryLocation` GeoJSON Feature (including nested `properties` keys) is a best-effort conversion from MSSQL's `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` syntax.

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` | ✓ converted |
| `purchasing.supplier_categories` | `postgres/Purchasing/Tables/SupplierCategories.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.cities` | `postgres/Application/Tables/Cities.sql` | ✓ converted |
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` | ✓ converted |

## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
