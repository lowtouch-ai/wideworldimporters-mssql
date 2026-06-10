# invoice_customer_orders

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql`

## Summary

Invoices a set of fully-picked sales orders: allocates invoice IDs, creates invoice and invoice line records, records stock item transactions, decrements stock holdings, and creates customer transaction records.

## Conversion notes

- `@OrdersToInvoice Website.OrderIDList READONLY` TVP → `p_OrdersToInvoice jsonb` (array of integers or `{"OrderID": n}` objects)
- `NEXT VALUE FOR Sequences.InvoiceID` → `nextval('sequences.invoice_id_seq')`
- `DECLARE @var AS TABLE (...)` → `CREATE TEMP TABLE ... ON COMMIT DROP`
- `SYSDATETIME()` → `CURRENT_TIMESTAMP`
- `JSON_MODIFY(N'{"Events": []}', N'append $.Events', ...)` → `jsonb_build_object(...)::text`
- `CONVERT(nvarchar(20), SYSDATETIME(), 126)` → `to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS')`
- `IsChillerStock <> 0` → `IsChillerStock = true`
- `sih.QuantityOnHand -= sit.TotalQuantity` → `QuantityOnHand = sih.QuantityOnHand - sit.TotalQuantity`
- `BEGIN TRY/CATCH` → `BEGIN ... EXCEPTION WHEN OTHERS THEN ... END`
- Concatenation: `N', ' + c.DeliveryAddressLine2` → `|| ', ' ||`

## TODOs

- Caller must pass `p_OrdersToInvoice` as a jsonb array: `'[1, 2, 3]'::jsonb` (array of integers) — the function uses `jsonb_array_elements_text` to extract integer order IDs.
- Alternatively refactor to accept `integer[]` array parameter for simplicity.
- Verify `sequences.invoice_id_seq` is created before deploying.

## Dependencies

| Object | Status |
|---|---|
| `sales.invoices` | check postgres/Sales/Tables/Invoices.sql |
| `sales.invoicelines` | check postgres/Sales/Tables/InvoiceLines.sql |
| `sales.orders` | check postgres/Sales/Tables/Orders.sql |
| `sales.orderlines` | check postgres/Sales/Tables/OrderLines.sql |
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
| `sales.customertransactions` | check postgres/Sales/Tables/CustomerTransactions.sql |
| `warehouse.stockitems` | check postgres/Warehouse/Tables/StockItems.sql |
| `warehouse.stockitemholdings` | check postgres/Warehouse/Tables/StockItemHoldings.sql |
| `warehouse.stockitemtransactions` | check postgres/Warehouse/Tables/StockItemTransactions.sql |
| `application.transactiontypes` | check postgres/Application/Tables/TransactionTypes.sql |
| `sequences.invoice_id_seq` | check postgres/Sequences/ |
