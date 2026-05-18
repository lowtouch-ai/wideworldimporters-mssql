# Conversion summary: StateProvinceID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/StateProvinceID.sql`
- **Output:** `postgres/Sequences/Sequences/StateProvinceID.sql`

## Conversions applied
- `[Sequences].[StateProvinceID]` → `sequences.state_province_id_seq`
- `AS INT` → omitted
- `START WITH 54 INCREMENT BY 1` → `START 54 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
