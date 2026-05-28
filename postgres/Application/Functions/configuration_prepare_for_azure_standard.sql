-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_PrepareForAzureStandard.sql
-- NOTE: This SP removed features unsupported in Azure SQL Database Standard tier (columnstore,
--       in-memory OLTP). Both are no-ops in PostgreSQL, so this function simply calls the
--       equivalent removal stubs.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_prepare_for_azure_standard() RETURNS void AS $$
BEGIN
    PERFORM application.configuration_remove_columnstore_indexing();
    PERFORM application.configuration_disable_in_memory();
END;
$$ LANGUAGE plpgsql;
