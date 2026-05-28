# Conversion summary: PurchaseOrderLineID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/PurchaseOrderLineID.sql`
- **Output:** `postgres/Sequences/Sequences/PurchaseOrderLineID.sql`

## Conversions applied
- `[Sequences].[PurchaseOrderLineID]` → `sequences.purchase_order_line_id_seq`
- `AS INT` → omitted
- `START WITH 17086 INCREMENT BY 1` → `START 17086 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
