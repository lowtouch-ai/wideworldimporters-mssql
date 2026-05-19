-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePaymentMethodFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_payment_method_from_json(
    p_payment_method    text,
    p_payment_method_id integer,
    p_user_id           integer
) RETURNS void AS $$
BEGIN
    UPDATE application.payment_methods
    SET paymentmethodname = x."PaymentMethodName",
        lasteditedby      = p_user_id
    FROM jsonb_to_record(p_payment_method::jsonb) AS x("PaymentMethodName" varchar(50))
    WHERE payment_methods.paymentmethodid = p_payment_method_id;
END;
$$ LANGUAGE plpgsql;
