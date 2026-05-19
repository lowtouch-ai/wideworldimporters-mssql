CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.package_types AS
SELECT PackageTypeID, PackageTypeName
FROM warehouse.packagetypes;
