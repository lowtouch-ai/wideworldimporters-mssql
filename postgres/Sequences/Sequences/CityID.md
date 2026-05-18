# Conversion summary: CityID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/CityID.sql`
- **Output:** `postgres/Sequences/Sequences/CityID.sql`

## Conversions applied
- `[Sequences].[CityID]` → `sequences.city_id_seq`
- `AS INT` → omitted (PostgreSQL sequences are BIGINT by default; consuming table columns use INTEGER)
- `START WITH 38187 INCREMENT BY 1` → `START 38187 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
