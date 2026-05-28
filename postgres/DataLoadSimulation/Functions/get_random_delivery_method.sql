-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomDeliveryMethod.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_delivery_method(
) RETURNS integer AS $$
DECLARE
    v_id integer;
BEGIN
    SELECT "DeliveryMethodID" INTO v_id
    FROM application.deliverymethods
    WHERE "ValidTo" = '9999-12-31 23:59:59.999999'
    ORDER BY random()
    LIMIT 1;

    RETURN v_id;
END;
$$ LANGUAGE plpgsql;
