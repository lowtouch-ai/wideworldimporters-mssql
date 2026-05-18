# Conversion summary: SupplierID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/SupplierID.sql`
- **Output:** `postgres/Sequences/Sequences/SupplierID.sql`

## Conversions applied
- `[Sequences].[SupplierID]` → `sequences.supplier_id_seq`
- `AS INT` → omitted
- `START WITH 14 INCREMENT BY 1` → `START 14 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
