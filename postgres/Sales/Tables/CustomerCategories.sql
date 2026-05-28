CREATE SCHEMA IF NOT EXISTS sales;

CREATE SEQUENCE IF NOT EXISTS sequences.customer_category_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.customer_categories (
    CustomerCategoryID   INTEGER      DEFAULT nextval('sequences.customer_category_id_seq') NOT NULL,
    CustomerCategoryName VARCHAR(50)  NOT NULL,
    LastEditedBy         INTEGER      NOT NULL,
    ValidFrom            TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo              TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_CustomerCategories PRIMARY KEY (CustomerCategoryID),
    CONSTRAINT FK_Sales_CustomerCategories_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Sales_CustomerCategories_CustomerCategoryName UNIQUE (CustomerCategoryName)
);

COMMENT ON TABLE sales.customer_categories IS 'Categories for customers (ie restaurants, cafes, supermarkets, etc.)';
COMMENT ON COLUMN sales.customer_categories.CustomerCategoryID IS 'Numeric ID used for reference to a customer category within the database';
COMMENT ON COLUMN sales.customer_categories.CustomerCategoryName IS 'Full name of the category that customers can be assigned to';
