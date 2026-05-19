-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateDeliveryMethodFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_delivery_method_from_json(
    p_delivery_method text,
    p_delivery_method_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.deliverymethods SET
        DeliveryMethodName = json.DeliveryMethodName,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_delivery_method::jsonb) AS json(DeliveryMethodName varchar(50))
    WHERE DeliveryMethodID = p_delivery_method_id;
END;
$$ LANGUAGE plpgsql;
