# Conversion summary: WebApi.CustomerTransactions

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/CustomerTransactions.sql`
- **Output:** `postgres/WebApi/Views/customer_transactions.sql`

## Conversions applied
- `[WebApi].[CustomerTransactions]` → `webapi.customer_transactions`
- `LEFT OUTER JOIN` → `LEFT JOIN` (2 occurrences)
- `Sales.CustomerTransactions` → `sales.customertransactions`
- `Sales.Customers` → `sales.customers`
- `Sales.Invoices` → `sales.invoices`
- `Application.TransactionTypes` → `application.transaction_types`
- `Application.PaymentMethods` → `application.payment_methods`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` | ✓ converted |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | ✓ converted |
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` | ✓ converted |
| `application.transaction_types` | `postgres/Application/Tables/TransactionTypes.sql` | ✓ converted |
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` | ✓ converted |
