\echo 'Inserting application.delivery_methods'
;

INSERT INTO application.delivery_methods
  (DeliveryMethodID, DeliveryMethodName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  (1,'Post', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (2,'Courier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (3,'Delivery Van', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (4,'Customer Collect', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (5,'Van with Chiller', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (6,'Customer Courier to Collect', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (7,'Road Freight', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (8,'Air Freight', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (9,'Refrigerated Road Freight', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (10,'Refrigerated Air Freight', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
