# Conversion summary: DataLoadSimulation.DeactivateTemporalTablesBeforeDataLoad

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DeactivateTemporalTablesBeforeDataLoad.sql`
- **Pattern:** Stub (no-op)
- **Output:** `postgres/DataLoadSimulation/Functions/deactivate_temporal_tables_before_data_load.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.deactivate_temporal_tables_before_data_load() RETURNS void
```

## Conversion notes
- Original SP used `ALTER TABLE ... SET (SYSTEM_VERSIONING = OFF)` — no PostgreSQL equivalent
- Converted to a no-op stub with `RAISE NOTICE`

## TODOs
- None (intentional stub)

## Tables referenced
None (DDL-only SP)
