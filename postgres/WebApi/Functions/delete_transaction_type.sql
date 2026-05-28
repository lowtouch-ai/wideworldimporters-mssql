-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteTransactionType.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_transaction_type(
    p_transaction_type_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.transaction_types
    WHERE TransactionTypeID = p_transaction_type_id;
END;
$$ LANGUAGE plpgsql;
