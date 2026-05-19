-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateTransactionTypeFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_transaction_type_from_json(
    p_transaction_type text,
    p_transaction_type_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.transactiontypes SET
        TransactionTypeName = json.TransactionTypeName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_transaction_type::jsonb) AS json(TransactionTypeName varchar(50))
    WHERE TransactionTypeID = p_transaction_type_id;
END;
$$ LANGUAGE plpgsql;
