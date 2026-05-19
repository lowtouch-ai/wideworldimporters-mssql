-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyColumnstoreIndexing.sql
-- NOTE: Columnstore indexes (NONCLUSTERED COLUMNSTORE INDEX, CLUSTERED COLUMNSTORE INDEX)
--       have no equivalent in PostgreSQL. BRIN indexes are the closest analogue for
--       sequential append-heavy tables but do not provide the same columnar compression
--       or analytical performance characteristics.
--       This function is a no-op stub.
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_apply_columnstore_indexing() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'Columnstore indexes are not supported in PostgreSQL. No action taken.';
    RAISE NOTICE 'Consider BRIN indexes for append-heavy tables or a columnar extension (e.g. citus columnar).';
END;
$$ LANGUAGE plpgsql;
