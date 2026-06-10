CREATE SCHEMA IF NOT EXISTS purchasing;

CREATE TABLE purchasing.suppliercategories_archive (
    SupplierCategoryID   INTEGER      NOT NULL,
    SupplierCategoryName VARCHAR(50)  NOT NULL,
    LastEditedBy         INTEGER      NOT NULL,
    ValidFrom            TIMESTAMP(6) NOT NULL,
    ValidTo              TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_SupplierCategories_Archive ON purchasing.suppliercategories_archive (ValidTo ASC, ValidFrom ASC);
