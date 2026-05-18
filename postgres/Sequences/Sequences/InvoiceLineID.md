# Conversion summary: InvoiceLineID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/InvoiceLineID.sql`
- **Output:** `postgres/Sequences/Sequences/InvoiceLineID.sql`

## Conversions applied
- `[Sequences].[InvoiceLineID]` → `sequences.invoice_line_id_seq`
- `AS INT` → omitted
- `START WITH 485930 INCREMENT BY 1` → `START 485930 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
