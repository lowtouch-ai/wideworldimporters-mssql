# Conversion summary: PurchaseOrders.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/PurchaseOrders.sql`
- **Output:** `postgres/Purchasing/Tables/PurchaseOrders.sql`

## Conversions applied
- `[Purchasing].[PurchaseOrders]` → `purchasing.purchaseorders`
- `INT` → `INTEGER`
- `NVARCHAR(20)` → `VARCHAR(20)`
- `NVARCHAR(MAX)` → `TEXT`
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[PurchaseOrderID]` → `nextval('sequences.purchase_order_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 3 × `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 3 index-level extended properties → omitted (with comment)
- 1 table-level extended property → `COMMENT ON TABLE`
- 10 column-level extended properties → `COMMENT ON COLUMN`
