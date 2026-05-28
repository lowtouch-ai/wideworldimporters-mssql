-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCustomerCount.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_customer_count(
    p_customer_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _cust_count integer;
BEGIN
    SELECT COUNT(*) INTO _cust_count
    FROM sales.customers
    WHERE CustomerName = p_customer_name;

    RETURN _cust_count;
END;
$$ LANGUAGE plpgsql;
