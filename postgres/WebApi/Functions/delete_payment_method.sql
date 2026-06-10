-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePaymentMethod.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_payment_method(
    p_payment_method_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.paymentmethods
    WHERE PaymentMethodID = p_payment_method_id;
END;
$$ LANGUAGE plpgsql;
