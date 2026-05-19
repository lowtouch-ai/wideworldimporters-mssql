CREATE SCHEMA IF NOT EXISTS purchasing;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.supplier_category_id_seq START 10 INCREMENT 1;

CREATE TABLE purchasing.suppliercategories (
    SupplierCategoryID   INTEGER             DEFAULT nextval('sequences.supplier_category_id_seq') NOT NULL,
    SupplierCategoryName VARCHAR(50)         NOT NULL,
    LastEditedBy         INTEGER             NOT NULL,
    ValidFrom            TIMESTAMP(6)        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo              TIMESTAMP(6)        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Purchasing_SupplierCategories PRIMARY KEY (SupplierCategoryID),
    CONSTRAINT FK_Purchasing_SupplierCategories_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Purchasing_SupplierCategories_SupplierCategoryName UNIQUE (SupplierCategoryName)
);

COMMENT ON TABLE purchasing.suppliercategories IS 'Categories for suppliers (ie novelties, toys, clothing, packaging, etc.)';
COMMENT ON COLUMN purchasing.suppliercategories.SupplierCategoryID IS 'Numeric ID used for reference to a supplier category within the database';
COMMENT ON COLUMN purchasing.suppliercategories.SupplierCategoryName IS 'Full name of the category that suppliers can be assigned to';
