-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPackageTypesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_package_types_from_json(
    p_package_types text,
    p_user_id       integer
) RETURNS TABLE(packagetypeid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO warehouse.package_types(packagetypename, lasteditedby)
    SELECT x."PackageTypeName", p_user_id
    FROM jsonb_to_recordset(p_package_types::jsonb) AS x("PackageTypeName" varchar(50))
    RETURNING package_types.packagetypeid;
END;
$$ LANGUAGE plpgsql;
