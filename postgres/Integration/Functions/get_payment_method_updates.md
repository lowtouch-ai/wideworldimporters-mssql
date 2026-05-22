# Conversion summary: Integration.GetPaymentMethodUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPaymentMethodUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_payment_method_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_payment_method_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Payment Method ID" integer,
    "Payment Method" varchar(50),
    "Valid From" timestamp,
    "Valid To" timestamp
)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@LastCutoff datetime2(7)` | `p_last_cutoff timestamp` | timestamp | Lower bound (exclusive) |
| `@NewCutoff datetime2(7)` | `p_new_cutoff timestamp` | timestamp | Upper bound (inclusive) |

## Conversion notes
- `DECLARE @EndOfTime datetime2(7) = '9999...'` → PL/pgSQL `_end_of_time timestamp := '9999-12-31 23:59:59.9999999'`
- `CREATE TABLE #PaymentMethodChanges` → `DROP TABLE IF EXISTS paymentmethodchanges; CREATE TEMP TABLE paymentmethodchanges (...)` (drop-before-create for idempotency across calls in the same session)
- `DECLARE ChangeList CURSOR FAST_FORWARD … OPEN … FETCH … WHILE @@FETCH_STATUS = 0` → `FOR rec IN (UNION ALL query) LOOP`
- `INSERT #PaymentMethodChanges` → `INSERT INTO paymentmethodchanges`
- `CREATE INDEX IX_PaymentMethodChanges` → `CREATE INDEX ix_paymentmethodchanges`
- `UPDATE cc SET … FROM #PaymentMethodChanges AS cc` → `UPDATE paymentmethodchanges AS cc SET …`
- `DROP TABLE #PaymentMethodChanges` → `DROP TABLE IF EXISTS paymentmethodchanges`
- Final `SELECT … FROM #PaymentMethodChanges` → `RETURN QUERY SELECT … FROM paymentmethodchanges`
- Column names with spaces double-quoted throughout

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom** — Not supported natively in PostgreSQL. Approximation uses archive table with `ValidFrom <= ts AND ValidTo > ts` UNION current-table fallback, taking the most recent match (ORDER BY ValidFrom DESC LIMIT 1). Verify this returns the correct version for all edge cases.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.paymentmethods_archive` | `postgres/Application/Tables/PaymentMethods_Archive.sql` |
| `application.paymentmethods` | `postgres/Application/Tables/PaymentMethods.sql` |
