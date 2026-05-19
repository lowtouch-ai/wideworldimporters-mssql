-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomer.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_customer(
    p_customer_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.customers
    WHERE CustomerID = p_customer_id;
END;
$$ LANGUAGE plpgsql;
