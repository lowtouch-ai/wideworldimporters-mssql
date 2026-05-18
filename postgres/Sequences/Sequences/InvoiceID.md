# Conversion summary: InvoiceID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/InvoiceID.sql`
- **Output:** `postgres/Sequences/Sequences/InvoiceID.sql`

## Conversions applied
- `[Sequences].[InvoiceID]` → `sequences.invoice_id_seq`
- `AS INT` → omitted
- `START WITH 149911 INCREMENT BY 1` → `START 149911 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
