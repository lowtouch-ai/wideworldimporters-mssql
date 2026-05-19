-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCitiesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_cities_from_json(
    p_cities text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO application.cities (CityName, StateProvinceID, LatestRecordedPopulation, LastEditedBy)
    SELECT x.CityName, x.StateProvinceID, x.LatestRecordedPopulation, p_user_id
    FROM jsonb_to_recordset(p_cities::jsonb) AS x(
        CityName varchar(50),
        StateProvinceID integer,
        LatestRecordedPopulation bigint
    );
END;
$$ LANGUAGE plpgsql;
