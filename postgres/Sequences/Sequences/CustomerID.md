# Conversion summary: CustomerID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/CustomerID.sql`
- **Output:** `postgres/Sequences/Sequences/CustomerID.sql`

## Conversions applied
- `[Sequences].[CustomerID]` → `sequences.customer_id_seq`
- `AS INT` → omitted
- `START WITH 1110 INCREMENT BY 1` → `START 1110 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
