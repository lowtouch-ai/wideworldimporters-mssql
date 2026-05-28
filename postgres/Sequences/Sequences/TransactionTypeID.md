# Conversion summary: TransactionTypeID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/TransactionTypeID.sql`
- **Output:** `postgres/Sequences/Sequences/TransactionTypeID.sql`

## Conversions applied
- `[Sequences].[TransactionTypeID]` → `sequences.transaction_type_id_seq`
- `AS INT` → omitted
- `START WITH 15 INCREMENT BY 1` → `START 15 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
