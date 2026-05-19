# Conversion summary: Integration.GetTransactionTypeUpdates

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionTypeUpdates.sql`
- **Pattern:** Complex / cursor / temporal
- **Output:** `postgres/Integration/Functions/get_transaction_type_updates.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION integration.get_transaction_type_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Transaction Type ID" integer,
    "Transaction Type" varchar(50),
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
- Structurally identical to `GetPaymentMethodUpdates` — same cursor + temp table + temporal + UPDATE + SELECT pattern applied to TransactionTypes
- `DECLARE @EndOfTime datetime2(7) = '9999...'` → `_end_of_time timestamp := '9999-12-31 23:59:59.9999999'`
- `CREATE TABLE #TransactionTypeChanges` → `DROP TABLE IF EXISTS transactiontypechanges; CREATE TEMP TABLE transactiontypechanges (...)`
- `DECLARE ChangeList CURSOR FAST_FORWARD … WHILE @@FETCH_STATUS = 0` → `FOR rec IN (UNION ALL query) LOOP`
- `INSERT #TransactionTypeChanges` → `INSERT INTO transactiontypechanges`
- `CREATE INDEX IX_TransactionTypeChanges` → `CREATE INDEX ix_transactiontypechanges`
- `UPDATE cc SET … FROM #TransactionTypeChanges AS cc` → `UPDATE transactiontypechanges AS cc SET …`
- `DROP TABLE #TransactionTypeChanges` → `DROP TABLE IF EXISTS transactiontypechanges`
- Final SELECT → `RETURN QUERY SELECT … FROM transactiontypechanges`
- Column names with spaces double-quoted throughout

## TODOs
- **FOR SYSTEM_TIME AS OF rec.validfrom** — Not supported natively in PostgreSQL. Approximation uses archive table with `ValidFrom <= ts AND ValidTo > ts` UNION current-table fallback, taking the most recent match (ORDER BY ValidFrom DESC LIMIT 1).

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.transactiontypes_archive` | `postgres/Application/Tables/TransactionTypes_Archive.sql` |
| `application.transactiontypes` | `postgres/Application/Tables/TransactionTypes.sql` |
