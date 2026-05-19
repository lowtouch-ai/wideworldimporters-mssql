# Conversion summary: WebApi.Invoices

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/Invoices.sql`
- **Output:** `postgres/WebApi/Views/invoices.sql`

## Conversions applied
- `[WebApi].[Invoices]` → `webapi.invoices`
- `INNER JOIN` → `JOIN` (4 occurrences)
- Column alias `ReturnedDeliveryData = JSON_QUERY(inv.ReturnedDeliveryData)` → `inv.ReturnedDeliveryData` (column referenced directly; stored as TEXT with JSON check constraint)
- `Sales.Invoices` → `sales.invoices`
- `Sales.Customers` → `sales.customers`
- `Application.DeliveryMethods` → `application.delivery_methods`
- `Application.People` → `application.people`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` | ✓ converted |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
