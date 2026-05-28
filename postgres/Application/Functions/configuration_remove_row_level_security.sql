-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_RemoveRowLevelSecurity.sql
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_remove_row_level_security() RETURNS void AS $$
BEGIN
    DROP POLICY IF EXISTS filter_customers_by_territory ON sales.customers;
    DROP POLICY IF EXISTS block_customers_update_by_territory ON sales.customers;

    ALTER TABLE sales.customers DISABLE ROW LEVEL SECURITY;

    -- TODO: The MSSQL version also dropped the DetermineCustomerAccess function.
    --       In PostgreSQL the function is managed separately; drop it manually if needed:
    --       DROP FUNCTION IF EXISTS application.determine_customer_access(integer);

    RAISE NOTICE 'Successfully removed row level security';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Unable to remove row level security';
    RAISE;
END;
$$ LANGUAGE plpgsql;
