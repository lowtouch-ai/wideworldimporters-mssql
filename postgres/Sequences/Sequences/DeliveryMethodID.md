# Conversion summary: DeliveryMethodID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/DeliveryMethodID.sql`
- **Output:** `postgres/Sequences/Sequences/DeliveryMethodID.sql`

## Conversions applied
- `[Sequences].[DeliveryMethodID]` → `sequences.delivery_method_id_seq`
- `AS INT` → omitted
- `START WITH 11 INCREMENT BY 1` → `START 11 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
