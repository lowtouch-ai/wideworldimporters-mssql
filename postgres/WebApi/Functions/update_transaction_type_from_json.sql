-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateTransactionTypeFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_transaction_type_from_json(
    p_transaction_type text,
    p_transaction_type_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.transactiontypes SET
        "TransactionTypeName" = json.transaction_type_name,
        "LastEditedBy" = p_user_id
    FROM jsonb_to_recordset(p_transaction_type::jsonb) AS json(
        transaction_type_name varchar(50)
    )
    WHERE application.transactiontypes."TransactionTypeID" = p_transaction_type_id;
END;
$$ LANGUAGE plpgsql;
