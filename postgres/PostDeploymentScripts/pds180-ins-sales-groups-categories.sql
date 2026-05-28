\echo 'Inserting sales.buying_groups'
;

INSERT INTO sales.buying_groups
  (BuyingGroupID, BuyingGroupName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  ( 1, 'Individual Buyers', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 2, 'Tailspin Toys', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 3, 'Wingtip Toys', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 4, 'Contoso Suites', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 5, 'Alpine Ski House', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 6, 'First Up Consultants', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 7, 'Fourth Coffee', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 8, 'Liberty''s Delightful Sinful Bakery & Cafe', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, ( 9, 'Munson''s Pickles and Preserves Farm', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (10, 'Margie''s Travel', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (11, 'Northwind Traders', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (12, 'Southridge Video', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (13, 'VanArsdel, Ltd.', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (14, 'Relecloud', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (15, 'Blue Younder Airlines', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
\echo 'Inserting sales.customer_categories'
;

INSERT INTO sales.customer_categories
  (CustomerCategoryID, CustomerCategoryName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  (1,'Agent', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (2,'Wholesaler', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (3,'Novelty Shop', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (4,'Supermarket', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (5,'Computer Store', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (6,'Gift Store', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (7,'Corporate', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
