-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ConfigureForEnterpriseEdition.sql
-- NOTE: This SP aggregated several SQL Server Enterprise Edition features (columnstore,
--       full-text, in-memory OLTP, partitioning). In PostgreSQL, the relevant equivalent
--       functions are called below. Columnstore / in-memory / partitioning stubs are no-ops;
--       full-text indexing creates GIN indexes.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_configure_for_enterprise_edition() RETURNS void AS $$
BEGIN
    PERFORM application.configuration_apply_columnstore_indexing();
    PERFORM application.configuration_apply_full_text_indexing();
    PERFORM application.configuration_enable_in_memory();
    PERFORM application.configuration_apply_partitioning();
END;
$$ LANGUAGE plpgsql;
