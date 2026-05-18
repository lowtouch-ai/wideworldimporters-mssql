# Conversion summary: StockItemStockGroupID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/StockItemStockGroupID.sql`
- **Output:** `postgres/Sequences/Sequences/StockItemStockGroupID.sql`

## Conversions applied
- `[Sequences].[StockItemStockGroupID]` → `sequences.stock_item_stock_group_id_seq`
- `AS INT` → omitted
- `START WITH 885 INCREMENT BY 1` → `START 885 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
