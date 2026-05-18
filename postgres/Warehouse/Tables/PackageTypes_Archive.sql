CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.package_types_archive (
    PackageTypeID   INTEGER      NOT NULL,
    PackageTypeName VARCHAR(50)  NOT NULL,
    LastEditedBy    INTEGER      NOT NULL,
    ValidFrom       TIMESTAMP(6) NOT NULL,
    ValidTo         TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_PackageTypes_Archive ON warehouse.package_types_archive (ValidTo ASC, ValidFrom ASC);
