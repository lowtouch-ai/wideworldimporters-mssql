# Conversion summary: Invoices.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/Invoices.sql`
- **Output:** `postgres/Sales/Tables/Invoices.sql`

## Conversions applied
- `[Sales].[Invoices]` → `sales.invoices`
- `INT` → `INTEGER` (×9 columns)
- `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(5)` → `VARCHAR(5)` (×2), `NVARCHAR(MAX)` → `TEXT` (×5 columns)
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[InvoiceID]` → `nextval('sequences.invoice_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- Non-persisted computed columns `ConfirmedDeliveryTime` and `ConfirmedReceivedBy` → regular nullable `TIMESTAMP(6)` and `TEXT` columns with `-- NOTE` comments
- `isjson(...) <> 0` CHECK constraint → `ReturnedDeliveryData::jsonb IS NOT NULL`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×9, including INCLUDE clause preserved)
- 9 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 18 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `application.deliverymethods`, `sales.customers`, `sales.orders`) are already converted.
