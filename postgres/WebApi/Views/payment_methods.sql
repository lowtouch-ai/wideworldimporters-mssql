CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.payment_methods AS
SELECT PaymentMethodID, PaymentMethodName
FROM application.paymentmethods;
