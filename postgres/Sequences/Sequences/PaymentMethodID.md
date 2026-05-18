# Conversion summary: PaymentMethodID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/PaymentMethodID.sql`
- **Output:** `postgres/Sequences/Sequences/PaymentMethodID.sql`

## Conversions applied
- `[Sequences].[PaymentMethodID]` → `sequences.payment_method_id_seq`
- `AS INT` → omitted
- `START WITH 5 INCREMENT BY 1` → `START 5 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
