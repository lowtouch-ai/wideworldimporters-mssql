# Conversion summary: SupplierCategoryID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/SupplierCategoryID.sql`
- **Output:** `postgres/Sequences/Sequences/SupplierCategoryID.sql`

## Conversions applied
- `[Sequences].[SupplierCategoryID]` → `sequences.supplier_category_id_seq`
- `AS INT` → omitted
- `START WITH 10 INCREMENT BY 1` → `START 10 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
