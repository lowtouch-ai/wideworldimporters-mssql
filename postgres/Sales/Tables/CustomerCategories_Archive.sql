CREATE SCHEMA IF NOT EXISTS sales;

CREATE TABLE sales.customer_categories_archive (
    CustomerCategoryID   INTEGER      NOT NULL,
    CustomerCategoryName VARCHAR(50)  NOT NULL,
    LastEditedBy         INTEGER      NOT NULL,
    ValidFrom            TIMESTAMP(6) NOT NULL,
    ValidTo              TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_CustomerCategories_Archive ON sales.customer_categories_archive (ValidTo ASC, ValidFrom ASC);
