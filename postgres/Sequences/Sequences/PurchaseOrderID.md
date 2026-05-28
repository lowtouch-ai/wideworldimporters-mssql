# Conversion summary: PurchaseOrderID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/PurchaseOrderID.sql`
- **Output:** `postgres/Sequences/Sequences/PurchaseOrderID.sql`

## Conversions applied
- `[Sequences].[PurchaseOrderID]` → `sequences.purchase_order_id_seq`
- `AS INT` → omitted
- `START WITH 4427 INCREMENT BY 1` → `START 4427 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
