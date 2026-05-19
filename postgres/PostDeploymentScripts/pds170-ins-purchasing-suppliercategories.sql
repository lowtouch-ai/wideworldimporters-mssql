\echo 'Inserting purchasing.supplier_categories'
;

INSERT INTO purchasing.supplier_categories
  (SupplierCategoryID, SupplierCategoryName, LastEditedBy, ValidFrom, ValidTo)
VALUES
  (1,'Other Wholesaler', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (2,'Novelty Goods Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (3,'Toy Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (4,'Clothing Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (5,'Packaging Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (6,'Courier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (7,'Financial Services Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (8,'Marketing Services Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
, (9,'Insurance Services Supplier', 1, '2020-01-01 00:00:00'::TIMESTAMP(6), '9999-12-31 23:59:59.999999'::TIMESTAMP(6))
;
