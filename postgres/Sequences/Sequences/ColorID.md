# Conversion summary: ColorID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/ColorID.sql`
- **Output:** `postgres/Sequences/Sequences/ColorID.sql`

## Conversions applied
- `[Sequences].[ColorID]` → `sequences.color_id_seq`
- `AS INT` → omitted
- `START WITH 37 INCREMENT BY 1` → `START 37 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
