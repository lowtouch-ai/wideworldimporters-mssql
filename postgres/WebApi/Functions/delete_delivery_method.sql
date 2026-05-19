-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteDeliveryMethod.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_delivery_method(
    p_delivery_method_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.delivery_methods
    WHERE DeliveryMethodID = p_delivery_method_id;
END;
$$ LANGUAGE plpgsql;
