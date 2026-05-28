-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DeactivateTemporalTablesBeforeDataLoad.sql
-- TODO: No-op stub. The original SP disables SQL Server system-temporal versioning on 17 tables
-- and creates per-table audit triggers via dynamic SQL. PostgreSQL tables have no system-temporal
-- versioning to disable; ValidFrom/ValidTo are plain timestamptz columns. If an audit history
-- mechanism is needed, implement it with triggers or a custom history table approach.
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.deactivate_temporal_tables_before_data_load(
) RETURNS void AS $$
BEGIN
    RAISE NOTICE 'deactivate_temporal_tables_before_data_load: no-op in PostgreSQL (no system-temporal versioning to disable)';
END;
$$ LANGUAGE plpgsql;
