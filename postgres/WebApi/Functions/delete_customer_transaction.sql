CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_customer_transaction(
    p_customer_transaction_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM sales.customertransactions
    WHERE CustomerTransactionID = p_customer_transaction_id;
END;
$$ LANGUAGE plpgsql;
