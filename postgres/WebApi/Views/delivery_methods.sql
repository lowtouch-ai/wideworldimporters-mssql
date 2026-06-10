CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.delivery_methods AS
SELECT DeliveryMethodID, DeliveryMethodName
FROM application.deliverymethods;
