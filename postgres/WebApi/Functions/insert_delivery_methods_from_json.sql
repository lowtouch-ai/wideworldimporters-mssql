-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertDeliveryMethodsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_delivery_methods_from_json(
    p_delivery_methods text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO application.deliverymethods (DeliveryMethodName, LastEditedBy)
    SELECT x.DeliveryMethodName, p_user_id
    FROM jsonb_to_recordset(p_delivery_methods::jsonb) AS x(DeliveryMethodName varchar(50));
END;
$$ LANGUAGE plpgsql;
