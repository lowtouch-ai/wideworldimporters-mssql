-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetPaymentMethodID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_payment_method_id(
    p_payment_method_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _pay_method_id integer;
BEGIN
    SELECT PaymentMethodID INTO _pay_method_id
    FROM application.payment_methods
    WHERE PaymentMethodName = p_payment_method_name
      AND ValidTo = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN _pay_method_id;
END;
$$ LANGUAGE plpgsql;
