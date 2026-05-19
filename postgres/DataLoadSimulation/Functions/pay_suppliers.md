# Conversion summary: DataLoadSimulation.PaySuppliers

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PaySuppliers.sql`
- **Pattern:** TVP-based transaction (table variable + UPDATE + INSERT)
- **Output:** `postgres/DataLoadSimulation/Functions/pay_suppliers.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.pay_suppliers(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DECLARE @transactions_to_pay TABLE (...)` → `CREATE TEMP TABLE transactions_to_pay (...) ON COMMIT DROP`
- Calls `dataloadsimulation.get_transaction_type_id('Supplier Payment Issued')`
- Calls `dataloadsimulation.get_payment_method_id('EFT')`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
| `purchasing.suppliertransactions` | `postgres/Purchasing/Tables/SupplierTransactions.sql` |
