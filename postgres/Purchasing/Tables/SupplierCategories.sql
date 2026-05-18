CREATE SCHEMA IF NOT EXISTS purchasing;

CREATE SEQUENCE IF NOT EXISTS sequences.supplier_category_id_seq START 1 INCREMENT 1;

CREATE TABLE purchasing.supplier_categories (
    SupplierCategoryID   INTEGER      DEFAULT nextval('sequences.supplier_category_id_seq') NOT NULL,
    SupplierCategoryName VARCHAR(50)  NOT NULL,
    LastEditedBy         INTEGER      NOT NULL,
    ValidFrom            TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo              TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Purchasing_SupplierCategories PRIMARY KEY (SupplierCategoryID),
    CONSTRAINT FK_Purchasing_SupplierCategories_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Purchasing_SupplierCategories_SupplierCategoryName UNIQUE (SupplierCategoryName)
);

COMMENT ON TABLE purchasing.supplier_categories IS 'Categories for suppliers (ie novelties, toys, clothing, packaging, etc.)';
COMMENT ON COLUMN purchasing.supplier_categories.SupplierCategoryID IS 'Numeric ID used for reference to a supplier category within the database';
COMMENT ON COLUMN purchasing.supplier_categories.SupplierCategoryName IS 'Full name of the category that suppliers can be assigned to';
