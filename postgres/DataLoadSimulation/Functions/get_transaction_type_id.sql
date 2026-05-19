-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetTransactionTypeID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_transaction_type_id(
    p_transaction_type_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _trans_type_id integer;
BEGIN
    SELECT TransactionTypeID INTO _trans_type_id
    FROM application.transaction_types
    WHERE TransactionTypeName = p_transaction_type_name
      AND ValidTo = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN _trans_type_id;
END;
$$ LANGUAGE plpgsql;
