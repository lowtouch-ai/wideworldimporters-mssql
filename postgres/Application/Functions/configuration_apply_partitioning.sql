-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyPartitioning.sql
-- NOTE: MSSQL partition functions and schemes (CREATE PARTITION FUNCTION / SCHEME) have no
--       direct runtime equivalent in PostgreSQL. PostgreSQL declarative partitioning is defined
--       at table-creation time via PARTITION BY RANGE / LIST / HASH. Converting the
--       WideWorldImporters partitioning scheme requires recreating the affected tables as
--       partitioned tables — a one-time DDL migration, not a runtime procedure.
--       This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_apply_partitioning() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'MSSQL partition functions and schemes are not supported in PostgreSQL.';
    RAISE NOTICE 'Implement partitioning at table-creation time using PARTITION BY RANGE in the table DDL.';
    RAISE NOTICE 'See: https://www.postgresql.org/docs/current/ddl-partitioning.html';
END;
$$ LANGUAGE plpgsql;
