# Conversion summary: CountryID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/CountryID.sql`
- **Output:** `postgres/Sequences/Sequences/CountryID.sql`

## Conversions applied
- `[Sequences].[CountryID]` → `sequences.country_id_seq`
- `AS INT` → omitted
- `START WITH 242 INCREMENT BY 1` → `START 242 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
