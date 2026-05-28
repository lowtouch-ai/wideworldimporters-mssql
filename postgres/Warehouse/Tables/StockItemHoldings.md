# Conversion summary: StockItemHoldings.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/StockItemHoldings.sql`
- **Output:** `postgres/Warehouse/Tables/StockItemHoldings.sql`

## Conversions applied
- `[Warehouse].[StockItemHoldings]` → `warehouse.stockitemholdings`
- `INT` → `INTEGER`
- `NVARCHAR(20)` → `VARCHAR(20)`
- `DECIMAL(18,2)` → `NUMERIC(18,2)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 1 table-level extended property → `COMMENT ON TABLE`
- 7 column-level extended properties → `COMMENT ON COLUMN`
