# Conversion summary: OrderID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/OrderID.sql`
- **Output:** `postgres/Sequences/Sequences/OrderID.sql`

## Conversions applied
- `[Sequences].[OrderID]` → `sequences.order_id_seq`
- `AS INT` → omitted
- `START WITH 156458 INCREMENT BY 1` → `START 156458 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
