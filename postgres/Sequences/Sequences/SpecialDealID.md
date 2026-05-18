# Conversion summary: SpecialDealID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/SpecialDealID.sql`
- **Output:** `postgres/Sequences/Sequences/SpecialDealID.sql`

## Conversions applied
- `[Sequences].[SpecialDealID]` → `sequences.special_deal_id_seq`
- `AS INT` → omitted
- `START WITH 5 INCREMENT BY 1` → `START 5 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
