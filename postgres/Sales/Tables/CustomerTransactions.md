# Conversion summary: CustomerTransactions.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/CustomerTransactions.sql`
- **Output:** `postgres/Sales/Tables/CustomerTransactions.sql`

## Conversions applied
- `[Sales].[CustomerTransactions]` → `sales.customertransactions`
- `INT` → `INTEGER` (×4 columns)
- `DECIMAL(18, 2)` → `NUMERIC(18, 2)` (×4 columns)
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[TransactionID]` → `nextval('sequences.transaction_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY NONCLUSTERED` → `PRIMARY KEY`
- Persisted computed column `IsFinalized` → `BOOLEAN GENERATED ALWAYS AS (CASE WHEN FinalizationDate IS NULL THEN FALSE ELSE TRUE END) STORED`; `CONVERT([bit], ...)` → `FALSE`/`TRUE` literals
- Partition scheme `PS_TransactionDate` omitted on all 6 indexes (no PostgreSQL equivalent)
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (partition clause stripped)
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×5, partition clauses stripped)
- 5 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 13 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `sales.customers`, `sales.invoices`, `application.paymentmethods`, `application.transactiontypes`) are already converted.
