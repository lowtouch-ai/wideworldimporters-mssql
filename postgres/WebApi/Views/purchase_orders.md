# Conversion summary: WebApi.PurchaseOrders

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/PurchaseOrders.sql`
- **Output:** `postgres/WebApi/Views/purchase_orders.sql`

## Conversions applied
- `[WebApi].[PurchaseOrders]` → `webapi.purchase_orders`
- `INNER JOIN` → `JOIN` (2 occurrences)
- Column alias `ContactName = c.FullName` → `c.FullName AS ContactName`
- Column alias `ContactPhone = c.PhoneNumber` → `c.PhoneNumber AS ContactPhone`
- Column alias `ContactFax = c.FaxNumber` → `c.FaxNumber AS ContactFax`
- Column alias `ContactEmail = c.EmailAddress` → `c.EmailAddress AS ContactEmail`
- `Purchasing.PurchaseOrders` → `purchasing.purchaseorders`
- `Application.People` → `application.people`
- `Application.DeliveryMethods` → `application.delivery_methods`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` | ✓ converted |
| `application.people` | `postgres/Application/Tables/People.sql` | ✓ converted |
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | ✓ converted |
