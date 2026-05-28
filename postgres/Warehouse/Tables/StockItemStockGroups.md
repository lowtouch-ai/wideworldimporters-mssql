# Conversion summary: StockItemStockGroups.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemStockGroups.sql`
- **Output:** `postgres/Warehouse/Tables/StockItemStockGroups.sql`

## Conversions applied
- `[Warehouse].[StockItemStockGroups]` → `warehouse.stockitemstockgroups`
- `INT` → `INTEGER`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[StockItemStockGroupID]` → `nextval('sequences.stock_item_stock_group_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 2 × `UNIQUE NONCLUSTERED` → `UNIQUE`
- 2 constraint-level extended properties → omitted (no PostgreSQL equivalent)
- 1 table-level extended property → `COMMENT ON TABLE`
- 3 column-level extended properties → `COMMENT ON COLUMN`
