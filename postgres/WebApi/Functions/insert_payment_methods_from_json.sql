-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPaymentMethodsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_payment_methods_from_json(
    p_payment_methods text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO application.paymentmethods (PaymentMethodName, LastEditedBy)
    SELECT x.PaymentMethodName, p_user_id
    FROM jsonb_to_recordset(p_payment_methods::jsonb) AS x(PaymentMethodName varchar(50));
END;
$$ LANGUAGE plpgsql;
