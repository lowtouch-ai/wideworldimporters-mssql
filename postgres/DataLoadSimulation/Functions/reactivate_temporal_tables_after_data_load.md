# Conversion summary: DataLoadSimulation.ReactivateTemporalTablesAfterDataLoad

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReactivateTemporalTablesAfterDataLoad.sql`
- **Pattern:** Stub (no-op)
- **Output:** `postgres/DataLoadSimulation/Functions/reactivate_temporal_tables_after_data_load.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.reactivate_temporal_tables_after_data_load() RETURNS void
```

## Conversion notes
- Original SP used `ALTER TABLE ... SET (SYSTEM_VERSIONING = ON ...)` — no PostgreSQL equivalent
- Converted to a no-op stub with `RAISE NOTICE`

## TODOs
- None (intentional stub)

## Tables referenced
None (DDL-only SP)
