-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertDeliveryMethodsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_delivery_methods_from_json(
    p_delivery_methods text,
    p_user_id          integer
) RETURNS TABLE(deliverymethodid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO application.delivery_methods(deliverymethodname, lasteditedby)
    SELECT x."DeliveryMethodName", p_user_id
    FROM jsonb_to_recordset(p_delivery_methods::jsonb) AS x("DeliveryMethodName" varchar(50))
    RETURNING delivery_methods.deliverymethodid;
END;
$$ LANGUAGE plpgsql;
