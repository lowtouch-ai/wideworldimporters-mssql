# Conversion summary: WebApi.SupplierTransactions

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/WebApi/Views/SupplierTransactions.sql`
- **Output:** `postgres/WebApi/Views/supplier_transactions.sql`

## Conversions applied
- `[WebApi].[SupplierTransactions]` → `webapi.supplier_transactions`
- `LEFT OUTER JOIN` → `LEFT JOIN` (4 occurrences)
- `Purchasing.SupplierTransactions` → `purchasing.suppliertransactions`
- `Purchasing.PurchaseOrders` → `purchasing.purchaseorders`
- `Application.TransactionTypes` → `application.transaction_types`
- `Purchasing.Suppliers` → `purchasing.suppliers`
- `Application.PaymentMethods` → `application.payment_methods`

## Table dependencies
| Table | Postgres file | Status |
|---|---|---|
| `purchasing.suppliertransactions` | `postgres/Purchasing/Tables/SupplierTransactions.sql` | ✓ converted |
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` | ✓ converted |
| `application.transaction_types` | `postgres/Application/Tables/TransactionTypes.sql` | ✓ converted |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` | ✓ converted |
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` | ✓ converted |
