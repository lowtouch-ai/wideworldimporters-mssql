-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePackageTypeFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_package_type_from_json(
    p_package_type    text,
    p_package_type_id integer,
    p_user_id         integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.package_types
    SET packagetypename = x."PackageTypeName",
        lasteditedby    = p_user_id
    FROM jsonb_to_record(p_package_type::jsonb) AS x("PackageTypeName" varchar(50))
    WHERE package_types.packagetypeid = p_package_type_id;
END;
$$ LANGUAGE plpgsql;
