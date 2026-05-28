# Conversion summary: WebApi.SpecialDeals

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/SpecialDeals.sql`
- **Output:** `postgres/WebApi/Views/special_deals.sql`

## Conversions applied
- `[WebApi].[SpecialDeals]` → `webapi.special_deals`
- `LEFT OUTER JOIN` → `LEFT JOIN` (4 occurrences)
- `Sales.SpecialDeals` → `sales.specialdeals`
- `Warehouse.StockItems` → `warehouse.stockitems`
- `Sales.Customers` → `sales.customers`
- `Sales.CustomerCategories` → `sales.customer_categories`
- `Sales.BuyingGroups` → `sales.buying_groups`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.specialdeals` | `postgres/Sales/Tables/SpecialDeals.sql` | ✓ converted |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` | ✓ converted |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` | ✓ converted |
| `sales.buying_groups` | `postgres/Sales/Tables/BuyingGroups.sql` | ✓ converted |
