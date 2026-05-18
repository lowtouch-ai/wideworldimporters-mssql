# Conversion summary: OrderLineID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/OrderLineID.sql`
- **Output:** `postgres/Sequences/Sequences/OrderLineID.sql`

## Conversions applied
- `[Sequences].[OrderLineID]` → `sequences.order_line_id_seq`
- `AS INT` → omitted
- `START WITH 492602 INCREMENT BY 1` → `START 492602 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
