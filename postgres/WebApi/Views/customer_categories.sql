CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.customer_categories AS
SELECT CustomerCategoryID, CustomerCategoryName
FROM sales.customer_categories;
