# Conversion summary: DataLoadSimulation.GetPaymentMethodID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPaymentMethodID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_payment_method_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_payment_method_id(p_payment_method_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@PaymentMethodName NVARCHAR(50)` | `p_payment_method_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT TOP 1 ... FROM Application.PaymentMethods WHERE ... AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT ... FROM application.paymentmethods WHERE ... AND "ValidTo" = '9999-12-31 23:59:59.999999' LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel)
- `NVARCHAR(50)` → `varchar(50)`

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.paymentmethods` | `postgres/Application/Tables/PaymentMethods.sql` |
