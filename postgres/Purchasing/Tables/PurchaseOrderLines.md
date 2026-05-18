# Conversion summary: PurchaseOrderLines.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/PurchaseOrderLines.sql`
- **Output:** `postgres/Purchasing/Tables/PurchaseOrderLines.sql`

## Conversions applied
- `[Purchasing].[PurchaseOrderLines]` → `purchasing.purchaseorderlines`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`
- `DECIMAL(18,2)` → `NUMERIC(18,2)`
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[PurchaseOrderLineID]` → `nextval('sequences.purchase_order_line_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 4 × `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (1 with `INCLUDE` clause preserved)
- 4 index-level extended properties → omitted (with comment)
- 1 table-level extended property → `COMMENT ON TABLE`
- 9 column-level extended properties → `COMMENT ON COLUMN`
