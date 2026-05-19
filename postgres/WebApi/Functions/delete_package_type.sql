-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePackageType.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_package_type(
    p_package_type_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM warehouse.package_types
    WHERE PackageTypeID = p_package_type_id;
END;
$$ LANGUAGE plpgsql;
