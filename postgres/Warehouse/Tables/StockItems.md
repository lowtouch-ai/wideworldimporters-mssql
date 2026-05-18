# Conversion summary: StockItems.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItems.sql`
- **Output:** `postgres/Warehouse/Tables/StockItems.sql`

## Conversions applied
- `[Warehouse].[StockItems]` → `warehouse.stockitems`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`, `NVARCHAR(50)` → `VARCHAR(50)`, `NVARCHAR(20)` → `VARCHAR(20)`
- `NVARCHAR(MAX)` → `TEXT`
- `BIT` → `BOOLEAN`
- `DECIMAL(18,3)` → `NUMERIC(18,3)`, `DECIMAL(18,2)` → `NUMERIC(18,2)`
- `VARBINARY(MAX)` → `BYTEA`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[StockItemID]` → `nextval('sequences.stock_item_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- `CONSTRAINT [DF_...] DEFAULT (...)` named-default syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 4 × `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` clause dropped; `ValidFrom`/`ValidTo` columns converted from `GENERATED ALWAYS AS ROW START/END` to plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- 2 non-persisted computed columns (`Tags`, `SearchDetails`) → regular `TEXT NULL` columns with `-- NOTE: was a non-persisted computed column` comments
- 4 index-level extended properties → omitted (with comment)
- 1 table-level extended property → `COMMENT ON TABLE`
- 22 column-level extended properties → `COMMENT ON COLUMN`
