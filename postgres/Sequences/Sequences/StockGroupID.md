# Conversion summary: StockGroupID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/StockGroupID.sql`
- **Output:** `postgres/Sequences/Sequences/StockGroupID.sql`

## Conversions applied
- `[Sequences].[StockGroupID]` → `sequences.stock_group_id_seq`
- `AS INT` → omitted
- `START WITH 11 INCREMENT BY 1` → `START 11 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
