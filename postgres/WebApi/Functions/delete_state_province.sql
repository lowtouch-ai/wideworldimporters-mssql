-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStateProvince.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_state_province(
    p_state_province_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.state_provinces
    WHERE StateProvinceID = p_state_province_id;
END;
$$ LANGUAGE plpgsql;
