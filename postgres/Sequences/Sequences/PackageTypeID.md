# Conversion summary: PackageTypeID.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sequences/Sequences/PackageTypeID.sql`
- **Output:** `postgres/Sequences/Sequences/PackageTypeID.sql`

## Conversions applied
- `[Sequences].[PackageTypeID]` → `sequences.package_type_id_seq`
- `AS INT` → omitted
- `START WITH 15 INCREMENT BY 1` → `START 15 INCREMENT 1`
- `CREATE SEQUENCE` → `CREATE SEQUENCE IF NOT EXISTS`
- `CREATE SCHEMA IF NOT EXISTS sequences;` prepended
