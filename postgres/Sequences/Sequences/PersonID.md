# Conversion summary: PersonID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/PersonID.sql`
- **Output:** `postgres/Sequences/Sequences/PersonID.sql`

## Conversions applied
- `[Sequences].[PersonID]` → `sequences.person_id_seq`
- `AS INT` → omitted
- `START WITH 3310 INCREMENT BY 1` → `START 3310 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
