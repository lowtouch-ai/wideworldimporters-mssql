# Conversion summary: StockItemID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/StockItemID.sql`
- **Output:** `postgres/Sequences/Sequences/StockItemID.sql`

## Conversions applied
- `[Sequences].[StockItemID]` → `sequences.stock_item_id_seq`
- `AS INT` → omitted
- `START WITH 228 INCREMENT BY 1` → `START 228 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
