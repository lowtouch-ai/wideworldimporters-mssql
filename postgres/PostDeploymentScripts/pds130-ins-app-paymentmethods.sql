\echo 'Inserting application.payment_methods'
;

INSERT INTO application.payment_methods
  (PaymentMethodID, PaymentMethodName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  (1,'Cash', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (2,'Check', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (3,'Credit Card', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (4,'EFT', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
