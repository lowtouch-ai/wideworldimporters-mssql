-- Converted from: wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyRowLevelSecurity.sql
CREATE SCHEMA IF NOT EXISTS application;

CREATE OR REPLACE FUNCTION application.configuration_apply_row_level_security() RETURNS void AS $$
BEGIN
    -- Drop existing policies before recreating
    DROP POLICY IF EXISTS filter_customers_by_territory ON sales.customers;
    DROP POLICY IF EXISTS block_customers_update_by_territory ON sales.customers;

    ALTER TABLE sales.customers ENABLE ROW LEVEL SECURITY;

    -- FILTER PREDICATE → FOR SELECT USING: row visible only when determine_customer_access returns a row
    CREATE POLICY filter_customers_by_territory
        ON sales.customers
        FOR SELECT
        USING (
            EXISTS (
                SELECT 1
                  FROM application.determine_customer_access("DeliveryCityID")
            )
        );

    -- BLOCK PREDICATE AFTER UPDATE → FOR UPDATE WITH CHECK
    CREATE POLICY block_customers_update_by_territory
        ON sales.customers
        FOR UPDATE
        WITH CHECK (
            EXISTS (
                SELECT 1
                  FROM application.determine_customer_access("DeliveryCityID")
            )
        );

    RAISE NOTICE 'Successfully applied row level security';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Unable to apply row level security';
    RAISE;
END;
$$ LANGUAGE plpgsql;
