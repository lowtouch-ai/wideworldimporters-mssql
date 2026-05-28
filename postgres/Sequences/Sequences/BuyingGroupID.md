# Conversion summary: BuyingGroupID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/BuyingGroupID.sql`
- **Output:** `postgres/Sequences/Sequences/BuyingGroupID.sql`

## Conversions applied
- `[Sequences].[BuyingGroupID]` → `sequences.buying_group_id_seq`
- `AS INT` → omitted (PostgreSQL sequences are BIGINT by default; consuming table columns use INTEGER)
- `START WITH 3 INCREMENT BY 1` → `START 3 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
