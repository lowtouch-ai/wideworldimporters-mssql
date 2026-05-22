-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveColumnstoreIndexing.sql
-- NOTE: Columnstore indexes have no PostgreSQL equivalent; nothing to remove.
--       This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_remove_columnstore_indexing() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'Columnstore indexes are not supported in PostgreSQL. No action taken.';
END;
$$ LANGUAGE plpgsql;
