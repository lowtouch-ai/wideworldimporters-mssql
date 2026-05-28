# Conversion summary: DataLoadSimulation.ReceivePurchaseOrders

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReceivePurchaseOrders.sql`
- **Pattern:** Cursor / complex DML
- **Output:** `postgres/DataLoadSimulation/Functions/receive_purchase_orders.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.receive_purchase_orders(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DECLARE PurchaseOrderList CURSOR FAST_FORWARD READ_ONLY FOR ... WHILE @@FETCH_STATUS` → `FOR rec IN (...) LOOP`
- `UPDATE sih SET sih.QuantityOnHand += ...` → `SET "QuantityOnHand" = sih."QuantityOnHand" + ...`
- Direct subqueries for TransactionTypeID and PaymentMethodID instead of helper functions (as in original)
- `IsOrderFinalized = 0` → `= false`; `IsOrderLineFinalized = 1` → `= true`
- `CAST(CEILING(RAND() * 10000) AS nvarchar(20))` → `CAST(ceil(random() * 10000)::integer AS varchar(20))`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` |
| `purchasing.purchaseorderlines` | `postgres/Purchasing/Tables/PurchaseOrderLines.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `warehouse.stockitemtransactions` | `postgres/Warehouse/Tables/StockItemTransactions.sql` |
| `purchasing.suppliertransactions` | `postgres/Purchasing/Tables/SupplierTransactions.sql` |
| `application.transactiontypes` | `postgres/Application/Tables/TransactionTypes.sql` |
| `application.paymentmethods` | `postgres/Application/Tables/PaymentMethods.sql` |
