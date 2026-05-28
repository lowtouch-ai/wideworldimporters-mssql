# Conversion summary: StockGroups.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockGroups.sql`
- **Output:** `postgres/Warehouse/Tables/StockGroups.sql`

## Conversions applied
- `[Warehouse].[StockGroups]` → `warehouse.stock_groups`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[StockGroupID]` → `nextval('sequences.stock_group_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.stock_group_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Warehouse_StockGroups_StockGroupID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 2 column-level extended properties → `COMMENT ON COLUMN`

All FK dependencies resolved (`application.people` already converted).
