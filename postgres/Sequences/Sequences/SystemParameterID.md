# Conversion summary: SystemParameterID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/SystemParameterID.sql`
- **Output:** `postgres/Sequences/Sequences/SystemParameterID.sql`

## Conversions applied
- `[Sequences].[SystemParameterID]` → `sequences.system_parameter_id_seq`
- `AS INT` → omitted
- `START WITH 3 INCREMENT BY 1` → `START 3 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
