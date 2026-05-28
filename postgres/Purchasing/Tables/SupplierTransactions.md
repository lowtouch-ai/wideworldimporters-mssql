# Conversion summary: SupplierTransactions.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/SupplierTransactions.sql`
- **Output:** `postgres/Purchasing/Tables/SupplierTransactions.sql`

## Conversions applied
- `[Purchasing].[SupplierTransactions]` → `purchasing.suppliertransactions`
- `INT` → `INTEGER` (×4 columns)
- `NVARCHAR(20)` → `VARCHAR(20)`
- `DECIMAL(18, 2)` → `NUMERIC(18, 2)` (×4 columns)
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[TransactionID]` → `nextval('sequences.transaction_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY NONCLUSTERED` → `PRIMARY KEY`
- Persisted computed column `IsFinalized` → `BOOLEAN GENERATED ALWAYS AS (CASE WHEN FinalizationDate IS NULL THEN FALSE ELSE TRUE END) STORED`
- Partition scheme `PS_TransactionDate` omitted on all 6 indexes (no PostgreSQL equivalent)
- `CREATE CLUSTERED INDEX` → `CREATE INDEX` (partition clause stripped)
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×5, partition clauses stripped)
- 5 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 14 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `application.paymentmethods`, `application.transactiontypes`, `purchasing.purchaseorders`, `purchasing.suppliers`) are already converted.
