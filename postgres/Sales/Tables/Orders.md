# Conversion summary: Orders.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql`
- **Output:** `postgres/Sales/Tables/Orders.sql`

## Conversions applied
- `[Sales].[Orders]` → `sales.orders`
- `INT` → `INTEGER` (×6 columns)
- `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(MAX)` → `TEXT` (×3 columns)
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)` (×2 columns)
- `NEXT VALUE FOR [Sequences].[OrderID]` → `nextval('sequences.order_id_seq')` (sequence created in Session 1)
- Named default constraints removed (`CONSTRAINT [DF_Sales_Orders_*] DEFAULT (...)` → `DEFAULT ...`)
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (×4)
- 4 index-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 14 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

None — all referenced tables (`application.people`, `sales.customers`) are already converted.
