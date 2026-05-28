-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPackageTypesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_package_types_from_json(
    p_package_types text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO warehouse.packagetypes (PackageTypeName, LastEditedBy)
    SELECT x.PackageTypeName, p_user_id
    FROM jsonb_to_recordset(p_package_types::jsonb) AS x(PackageTypeName varchar(50));
END;
$$ LANGUAGE plpgsql;
