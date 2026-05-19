-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCity.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_city(
    p_city_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.cities
    WHERE CityID = p_city_id;
END;
$$ LANGUAGE plpgsql;
