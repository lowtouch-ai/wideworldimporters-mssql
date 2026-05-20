-- Creates the webapi application login role and grants read/execute access.
-- MSSQL used separate CREATE LOGIN (server-level) + CREATE USER (database-level).
-- PostgreSQL unifies both into a single role with the LOGIN attribute.
-- NOTE: Change the password before deploying to any non-development environment.

DO $$
BEGIN
    CREATE ROLE webapi WITH LOGIN PASSWORD 'Sp1d3rman!';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Schema-level access for the webapi schema (functions + views consumed by the app)
GRANT USAGE ON SCHEMA webapi TO webapi;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA webapi TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA webapi TO webapi;

-- Underlying schemas that webapi functions query directly
GRANT USAGE ON SCHEMA application, sales, purchasing, warehouse TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA application   TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA sales         TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA purchasing    TO webapi;
GRANT SELECT ON ALL TABLES IN SCHEMA warehouse     TO webapi;

-- Write access required by webapi insert/update/delete functions
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA application TO webapi;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA sales       TO webapi;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA purchasing  TO webapi;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA warehouse   TO webapi;

-- Sequence usage for webapi insert functions
GRANT USAGE ON ALL SEQUENCES IN SCHEMA sequences TO webapi;
