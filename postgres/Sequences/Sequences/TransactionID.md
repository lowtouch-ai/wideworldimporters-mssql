# Conversion summary: TransactionID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/TransactionID.sql`
- **Output:** `postgres/Sequences/Sequences/TransactionID.sql`

## Conversions applied
- `[Sequences].[TransactionID]` → `sequences.transaction_id_seq`
- `AS INT` → omitted
- `START WITH 714101 INCREMENT BY 1` → `START 714101 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
