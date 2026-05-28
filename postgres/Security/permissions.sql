-- Converted from: wwi-ssdt/wwi-ssdt/Security/Permissions.sql
--
-- MSSQL used separate CREATE LOGIN (server-level) + CREATE USER (database-level).
-- PostgreSQL unifies both into a single role with the LOGIN attribute.
--
-- GRANT CONNECT is implied by the LOGIN attribute; no separate statement needed.
-- GRANT EXECUTE ON SCHEMA::WebApi → USAGE on schema + EXECUTE on all functions.
-- GRANT SELECT ON SCHEMA::WebApi  → SELECT on all tables/views in schema.
-- Application.Logs → application.logs (schema and table names are lowercased per convention).
--
-- NOTE: Change the password before deploying to any non-development environment.

DO $$
BEGIN
    CREATE ROLE webapi WITH LOGIN PASSWORD 'Sp1d3rman!';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Schema-level access for the webapi schema
GRANT USAGE ON SCHEMA webapi TO webapi;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA webapi TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA webapi TO webapi;

-- Table-level access on Application.Logs
GRANT INSERT, SELECT ON application.logs TO webapi;
