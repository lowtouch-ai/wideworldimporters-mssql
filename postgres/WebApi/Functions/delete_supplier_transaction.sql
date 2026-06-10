CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_supplier_transaction(
    p_supplier_transaction_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM purchasing.suppliertransactions
    WHERE SupplierTransactionID = p_supplier_transaction_id;
END;
$$ LANGUAGE plpgsql;
