CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.supplier_categories AS
SELECT SupplierCategoryID, SupplierCategoryName
FROM purchasing.supplier_categories;
