-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPaymentMethodsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_payment_methods_from_json(
    p_payment_methods text,
    p_user_id         integer
) RETURNS TABLE(paymentmethodid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO application.payment_methods(paymentmethodname, lasteditedby)
    SELECT x."PaymentMethodName", p_user_id
    FROM jsonb_to_recordset(p_payment_methods::jsonb) AS x("PaymentMethodName" varchar(50))
    RETURNING payment_methods.paymentmethodid;
END;
$$ LANGUAGE plpgsql;
