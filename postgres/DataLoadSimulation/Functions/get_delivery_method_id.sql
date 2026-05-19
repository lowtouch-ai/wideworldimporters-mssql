-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetDeliveryMethodID.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_delivery_method_id(
    p_delivery_method_name varchar(50)
) RETURNS integer AS $$
DECLARE
    _deliv_method_id integer;
BEGIN
    SELECT DeliveryMethodID INTO _deliv_method_id
    FROM application.delivery_methods
    WHERE DeliveryMethodName = p_delivery_method_name
      AND ValidTo = '9999-12-31 23:59:59.999999'
    LIMIT 1;

    RETURN _deliv_method_id;
END;
$$ LANGUAGE plpgsql;
