# Conversion summary: Website.Customers

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/Views/Customers.sql`
- **Output:** `postgres/Website/Views/customers.sql`

## Conversions applied
- `[Website].[Customers]` → `website.customers`
- `LEFT OUTER JOIN` → `LEFT JOIN` (6 occurrences)
- `GO` statement removed
- `Sales.Customers` → `sales.customers`
- `Sales.CustomerCategories` → `sales.customer_categories`
- `[Application].People` → `application.people`
- `Sales.BuyingGroups` → `sales.buying_groups`
- `[Application].DeliveryMethods` → `application.delivery_methods`
- `[Application].Cities` → `application.cities`
- `s.DeliveryLocation` passed through directly as PostGIS `geography` column

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.cities` | `postgres/Application/Tables/Cities.sql` | ✓ converted |

## PostGIS note
This view exposes the `DeliveryLocation` geography column directly. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run.
