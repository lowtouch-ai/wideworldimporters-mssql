# Conversion summary: DataLoadSimulation.InvoicePickedOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/InvoicePickedOrders.sql`
- **Pattern:** Cursor / complex DML
- **Output:** `postgres/DataLoadSimulation/Functions/invoice_picked_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.invoice_picked_orders(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DECLARE OrderList CURSOR FAST_FORWARD READ_ONLY FOR ... OPEN/FETCH/WHILE @@FETCH_STATUS` → `FOR rec IN (...) LOOP`
- `NEXT VALUE FOR Sequences.OrderID` → `nextval('sequences.order_id_seq')`
- `NEXT VALUE FOR Sequences.InvoiceID` → `nextval('sequences.invoice_id_seq')`
- `JSON_MODIFY(@json, '$.Key', value)` → `jsonb_set(v_json, '{Key}', to_json(value)::jsonb)`
- `JSON_MODIFY(@json, 'append $.Events', JSON_QUERY(...))` → `jsonb_set(..., '{Events}', array || jsonb_build_array(event))`
- `CONVERT(nvarchar(20), ts, 126)` → `to_char(ts, 'YYYY-MM-DD"T"HH24:MI:SS')`
- `sih.QuantityOnHand -= ...` → `"QuantityOnHand" = "QuantityOnHand" - ...`
- `IsChillerStock <> 0` → `<> false`
- `ReturnedDeliveryData` stored as text; cast jsonb→text on write

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `sales.invoicelines` | `postgres/Sales/Tables/InvoiceLines.sql` |
| `sales.orderlines` | `postgres/Sales/Tables/OrderLines.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `warehouse.stockitemtransactions` | `postgres/Warehouse/Tables/StockItemTransactions.sql` |
