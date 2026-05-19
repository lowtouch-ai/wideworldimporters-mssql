\echo 'Inserting application.transaction_types'
;

INSERT INTO application.transaction_types
  (TransactionTypeID, TransactionTypeName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  (1,'Customer Invoice', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (2,'Customer Credit Note', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (3,'Customer Payment Received', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (4,'Customer Refund', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (5,'Supplier Invoice', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (6,'Supplier Credit Note', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (7,'Supplier Payment Issued', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (8,'Supplier Refund', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (9,'Stock Transfer', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (10,'Stock Issue', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (11,'Stock Receipt', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (12,'Stock Adjustment at Stocktake', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
