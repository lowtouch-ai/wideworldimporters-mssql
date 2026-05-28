# Conversion summary: InvoiceLines.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/InvoiceLines.sql`
- **Output:** `postgres/Sales/Tables/InvoiceLines.sql`

## Conversions applied
- `[Sales].[InvoiceLines]` → `sales.invoicelines`
- `INT` → `INTEGER` (×4 columns)
- `NVARCHAR(100)` → `VARCHAR(100)`
- `DECIMAL(18, 2)` → `NUMERIC(18, 2)` (×4), `DECIMAL(18, 3)` → `NUMERIC(18, 3)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[InvoiceLineID]` → `nextval('sequences.invoice_line_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE COLUMNSTORE INDEX` → omitted (no PostgreSQL equivalent)
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×3)
- 3 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 11 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `sales.invoices`, `warehouse.packagetypes`, `warehouse.stockitems`) are already converted.
