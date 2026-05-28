# Conversion summary: Website.InvoiceCustomerOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql`
- **Pattern:** TVP-based transaction → `RETURNS void`
- **Output:** `postgres/Website/Functions/invoice_customer_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.invoice_customer_orders(
    p_orders_to_invoice website.order_id_list[],
    p_packed_by_person_id integer,
    p_invoiced_by_person_id integer
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@OrdersToInvoice Website.OrderIDList READONLY` | `p_orders_to_invoice website.order_id_list[]` | composite type array | TVP → array of composite type |
| `@PackedByPersonID int` | `p_packed_by_person_id integer` | integer | |
| `@InvoicedByPersonID int` | `p_invoiced_by_person_id integer` | integer | |

## Conversion notes
- TVP `@OrdersToInvoice Website.OrderIDList READONLY` → `website.order_id_list[]`; iterated via `UNNEST(p_orders_to_invoice) AS oti`
- `@InvoicesToGenerate` table variable → `_invoices_to_generate` TEMP TABLE
- `NEXT VALUE FOR Sequences.InvoiceID` → `nextval('sequences.invoice_id_seq')`
- `IsChillerStock <> 0` → `ischillerstock` (boolean column, no comparison needed)
- `JSON_MODIFY(N'{"Events": []}', N'append $.Events', ...)` → `jsonb_build_object('Events', jsonb_build_array(jsonb_build_object(...)))::text`
- `CONVERT(nvarchar(20), SYSDATETIME(), 126)` → `to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS')` (ISO 8601 format 126)
- `[Application].TransactionTypes` → `application.transaction_types` (snake_case table name)
- `sih.QuantityOnHand -= sit.TotalQuantity` → `quantityonhand = quantityonhand - sit.totalquantity` via subquery FROM clause
- `c.DeliveryAddressLine1 + N', ' + c.DeliveryAddressLine2` → `deliveryaddressline1 || ', ' || COALESCE(deliveryaddressline2, '')` (handles NULL)
- `BEGIN TRAN`/`COMMIT` removed — caller's transaction context
- `BEGIN TRY ... BEGIN CATCH` → `EXCEPTION WHEN OTHERS THEN`

## TODOs
- Verify ReturnedDeliveryData JSON shape matches original `JSON_MODIFY` chain output

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `sales.invoicelines` | `postgres/Sales/Tables/InvoiceLines.sql` |
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `warehouse.stockitemtransactions` | `postgres/Warehouse/Tables/StockItemTransactions.sql` |
| `application.transaction_types` | `postgres/Application/Tables/TransactionTypes.sql` |
