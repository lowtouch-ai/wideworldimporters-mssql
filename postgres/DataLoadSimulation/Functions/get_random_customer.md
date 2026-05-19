# Conversion summary: DataLoadSimulation.GetRandomCustomer

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomer.sql`
- **Pattern:** Multi-value OUTPUT parameters → RETURNS TABLE(random_customer_id, customer_primary_contact_person_id)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_customer.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_customer()
RETURNS TABLE(random_customer_id integer, customer_primary_contact_person_id integer)
```

## Conversion notes
- `SELECT TOP(1) ... ORDER BY NEWID()` → `ORDER BY random() LIMIT 1`
- `IsOnCreditHold = 0` → `"IsOnCreditHold" = false` (bit → boolean)
- `ValidTo = '99991231 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
