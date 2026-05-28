-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePaymentMethodFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_payment_method_from_json(
    p_payment_method text,
    p_payment_method_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.paymentmethods SET
        PaymentMethodName = json.PaymentMethodName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_payment_method::jsonb) AS json(PaymentMethodName varchar(50))
    WHERE PaymentMethodID = p_payment_method_id;
END;
$$ LANGUAGE plpgsql;
