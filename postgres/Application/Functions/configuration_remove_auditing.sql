-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveAuditing.sql
-- NOTE: SQL Server Audit removal has no direct PostgreSQL equivalent.
--       To disable pgaudit, remove or comment out the pgaudit settings in postgresql.conf
--       and reload the server (SELECT pg_reload_conf()).
--       This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_remove_auditing() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'SQL Server Audit removal is not supported in PostgreSQL.';
    RAISE NOTICE 'To disable pgaudit, update postgresql.conf and run SELECT pg_reload_conf().';
END;
$$ LANGUAGE plpgsql;
