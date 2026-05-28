# Conversion summary: DataLoadSimulation.ProcessCustomerPayments

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ProcessCustomerPayments.sql`
- **Pattern:** TVP-based transaction (table variable + UPDATE + INSERT)
- **Output:** `postgres/DataLoadSimulation/Functions/process_customer_payments.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.process_customer_payments(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DECLARE @transactions_to_receive TABLE (...)` → `CREATE TEMP TABLE transactions_to_receive (...) ON COMMIT DROP`
- Calls `dataloadsimulation.get_transaction_type_id('Customer Payment Received')`
- Calls `dataloadsimulation.get_payment_method_id('EFT')`
- `0 - SUM(...)` preserved as negation

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customertransactions` | `postgres/Sales/Tables/CustomerTransactions.sql` |
