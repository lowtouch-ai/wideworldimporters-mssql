-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomer.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_customer(
) RETURNS TABLE(random_customer_id integer, customer_primary_contact_person_id integer) AS $$
BEGIN
    RETURN QUERY
    SELECT c."CustomerID", c."PrimaryContactPersonID"
    FROM sales.customers c
    WHERE c."IsOnCreditHold" = false
      AND c."ValidTo" = '9999-12-31 23:59:59.999999'
    ORDER BY random()
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;
