-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCountry.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.delete_country(
    p_country_id integer
) RETURNS void AS $$
BEGIN
    DELETE FROM application.countries
    WHERE CountryID = p_country_id;
END;
$$ LANGUAGE plpgsql;
