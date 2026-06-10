CREATE SCHEMA IF NOT EXISTS warehouse;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.package_type_id_seq START 15 INCREMENT 1;

CREATE TABLE warehouse.packagetypes (
    PackageTypeID   INTEGER      DEFAULT nextval('sequences.package_type_id_seq') NOT NULL,
    PackageTypeName VARCHAR(50)  NOT NULL,
    LastEditedBy    INTEGER      NOT NULL,
    ValidFrom       TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo         TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_PackageTypes PRIMARY KEY (PackageTypeID),
    CONSTRAINT FK_Warehouse_PackageTypes_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Warehouse_PackageTypes_PackageTypeName UNIQUE (PackageTypeName)
);

COMMENT ON TABLE warehouse.packagetypes IS 'Ways that stock items can be packaged (ie: each, box, carton, pallet, kg, etc.';
COMMENT ON COLUMN warehouse.packagetypes.PackageTypeID IS 'Numeric ID used for reference to a package type within the database';
COMMENT ON COLUMN warehouse.packagetypes.PackageTypeName IS 'Full name of package types that stock items can be purchased in or sold in';
