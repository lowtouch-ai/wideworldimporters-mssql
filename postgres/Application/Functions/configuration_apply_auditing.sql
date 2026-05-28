-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyAuditing.sql
-- NOTE: SQL Server Audit (server audit + audit specifications) has no direct PostgreSQL equivalent.
--       PostgreSQL auditing is provided by the pgaudit extension. Configure it via postgresql.conf:
--         shared_preload_libraries = 'pgaudit'
--         pgaudit.log = 'write, ddl, role'
--       This function is a no-op stub; enable pgaudit at the database/cluster level instead.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_apply_auditing() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'SQL Server Audit is not supported in PostgreSQL. Use the pgaudit extension instead.';
    RAISE NOTICE 'Set shared_preload_libraries = ''pgaudit'' and pgaudit.log = ''write, ddl, role'' in postgresql.conf.';
END;
$$ LANGUAGE plpgsql;
