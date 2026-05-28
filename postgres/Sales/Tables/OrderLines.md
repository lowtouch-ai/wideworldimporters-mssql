# Conversion summary: OrderLines.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/OrderLines.sql`
- **Output:** `postgres/Sales/Tables/OrderLines.sql`

## Conversions applied
- `[Sales].[OrderLines]` → `sales.orderlines`
- `INT` → `INTEGER` (×5 columns)
- `NVARCHAR(100)` → `VARCHAR(100)`
- `DECIMAL(18, 2)` → `NUMERIC(18, 2)`, `DECIMAL(18, 3)` → `NUMERIC(18, 3)`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×2)
- `NEXT VALUE FOR [Sequences].[OrderLineID]` → `nextval('sequences.order_line_id_seq')` (sequence created in Session 1)
- Named default constraints removed
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE COLUMNSTORE INDEX` → omitted (no PostgreSQL equivalent)
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×5, INCLUDE clauses preserved)
- 5 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 10 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `sales.orders`, `warehouse.packagetypes`, `warehouse.stockitems`) are already converted.
