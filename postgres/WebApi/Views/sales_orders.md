# Conversion summary: WebApi.SalesOrders

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/SalesOrders.sql`
- **Output:** `postgres/WebApi/Views/sales_orders.sql`

## Conversions applied
- `[WebApi].[SalesOrders]` → `webapi.sales_orders`
- `INNER JOIN` → `JOIN` (2 occurrences)
- `LEFT OUTER JOIN` → `LEFT JOIN` (1 occurrence)
- Column alias `DeliveryLocation = JSON_QUERY(...)` → `json_build_object(...)` (best-effort GeoJSON)
- Column alias `SalesPerson = sp.FullName` → `sp.FullName AS SalesPerson`
- Column alias `SalesPersonPhone = sp.PhoneNumber` → `sp.PhoneNumber AS SalesPersonPhone`
- Column alias `SalesPersonEmail = sp.EmailAddress` → `sp.EmailAddress AS SalesPersonEmail`
- `c.DeliveryLocation.Long` → `ST_X(c.DeliveryLocation::geometry)`
- `c.DeliveryLocation.Lat` → `ST_Y(c.DeliveryLocation::geometry)`
- `CONCAT('[', ..., ']')` coordinates array → `json_build_array(...)`
- `Sales.Orders` → `sales.orders`
- `Sales.Customers` → `sales.customers`
- `[Application].DeliveryMethods` → `application.delivery_methods`
- `Application.People` → `application.people`

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH output` — the `DeliveryLocation` GeoJSON Feature (including nested `properties` keys) is a best-effort conversion from MSSQL's `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` syntax.

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` | ✓ converted |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |

## PostGIS note
This view references PostGIS geography columns. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run and that the underlying tables are converted with their `geography` columns intact.
