# Conversion summary: SeasonVariation.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Tables/SeasonVariation.sql`
- **Output:** `postgres/DataLoadSimulation/Tables/SeasonVariation.sql`

## Conversions applied
- `DataLoadSimulation.SeasonVariation` → `dataloadsimulation.seasonvariation`
- `INT` → `INTEGER`
- `SMALLINT` → `SMALLINT` (unchanged)
- `FLOAT` → `DOUBLE PRECISION`
- Square-bracket quoting removed from `[Year]`, `[Season]`
- `PRIMARY KEY` retained (was already non-clustered composite)

## Next files to convert (unresolved dependencies)

None — this table has no foreign key references.
