# Conversion summary: StockItemTransactions.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemTransactions.sql`
- **Output:** `postgres/Warehouse/Tables/StockItemTransactions.sql`

## Conversions applied
- `[Warehouse].[StockItemTransactions]` → `warehouse.stockitemtransactions`
- `INT` → `INTEGER` (×6 columns)
- `DECIMAL(18, 3)` → `NUMERIC(18, 3)`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×2 columns)
- `NEXT VALUE FOR [Sequences].[TransactionID]` → `nextval('sequences.transaction_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY NONCLUSTERED` → `PRIMARY KEY`
- `CREATE CLUSTERED COLUMNSTORE INDEX` → omitted (no PostgreSQL equivalent)
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×6)
- 6 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 9 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `application.transactiontypes`, `sales.customers`, `sales.invoices`, `warehouse.stockitems`, `purchasing.purchaseorders`, `purchasing.suppliers`) are already converted.
