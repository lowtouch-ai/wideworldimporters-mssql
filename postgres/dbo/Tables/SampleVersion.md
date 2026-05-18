# Conversion summary: SampleVersion.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/dbo/Tables/SampleVersion.sql`
- **Output:** `postgres/dbo/Tables/SampleVersion.sql`

## Conversions applied
- `[dbo].[SampleVersion]` → `dbo.sampleversion`
- `INT` → `INTEGER` (×3 columns)
- `NVARCHAR(25)` → `VARCHAR(25)`
- Square-bracket quoting removed from `[RowCount]` column name
- `DEFAULT (1)` → `DEFAULT 1`
- `UNIQUE` and `CHECK` constraints retained (brackets removed from column references)

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
