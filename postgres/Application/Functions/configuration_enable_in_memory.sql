-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_EnableInMemory.sql
-- NOTE: SQL Server In-Memory OLTP (memory-optimized filegroup, MEMORY_OPTIMIZED=ON tables,
--       natively compiled stored procedures) has no equivalent in standard PostgreSQL.
--       All WideWorldImporters Website SPs that used In-Memory features are converted to
--       regular PL/pgSQL functions in this migration. This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_enable_in_memory() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'In-Memory OLTP is not supported in PostgreSQL. No action taken.';
END;
$$ LANGUAGE plpgsql;
