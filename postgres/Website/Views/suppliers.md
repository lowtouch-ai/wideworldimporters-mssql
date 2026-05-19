# Conversion summary: Website.Suppliers

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Website/Views/Suppliers.sql`
- **Output:** `postgres/Website/Views/suppliers.sql`

## Conversions applied
- `[Website].[Suppliers]` → `website.suppliers`
- `LEFT OUTER JOIN` → `LEFT JOIN` (5 occurrences)
- `GO` statement removed
- `Purchasing.Suppliers` → `purchasing.suppliers`
- `Purchasing.SupplierCategories` → `purchasing.supplier_categories`
- `[Application].People` → `application.people`
- `[Application].DeliveryMethods` → `application.delivery_methods`
- `[Application].Cities` → `application.cities`
- `s.DeliveryLocation` passed through directly as PostGIS `geography` column

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` | ✓ converted |
| `purchasing.supplier_categories` | `postgres/Purchasing/Tables/SupplierCategories.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.cities` | `postgres/Application/Tables/Cities.sql` | ✓ converted |

## PostGIS note
This view exposes the `DeliveryLocation` geography column directly. Ensure `CREATE EXTENSION IF NOT EXISTS postgis;` has been run.
