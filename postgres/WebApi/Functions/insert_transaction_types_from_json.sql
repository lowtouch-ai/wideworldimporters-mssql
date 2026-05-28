-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertTransactionTypesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_transaction_types_from_json(
    p_transaction_types text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO application.transactiontypes (TransactionTypeName, LastEditedBy)
    SELECT x.TransactionTypeName, p_user_id
    FROM jsonb_to_recordset(p_transaction_types::jsonb) AS x(TransactionTypeName varchar(50));
END;
$$ LANGUAGE plpgsql;
