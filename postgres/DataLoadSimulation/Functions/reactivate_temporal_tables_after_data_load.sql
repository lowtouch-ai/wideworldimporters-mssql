-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ReactivateTemporalTablesAfterDataLoad.sql
-- TODO: No-op stub. The original SP re-enables SQL Server system-temporal versioning (SYSTEM_VERSIONING = ON)
-- on 17 tables and drops the per-table audit triggers created by deactivate_temporal_tables_before_data_load.
-- PostgreSQL has no system-temporal versioning; this operation is not applicable.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.reactivate_temporal_tables_after_data_load(
) RETURNS void AS $$
BEGIN
    RAISE NOTICE 'reactivate_temporal_tables_after_data_load: no-op in PostgreSQL (no system-temporal versioning to re-enable)';
END;
$$ LANGUAGE plpgsql;
