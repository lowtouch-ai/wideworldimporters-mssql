-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCitiesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_cities_from_json(
    p_cities  text,
    p_user_id integer
) RETURNS TABLE(cityid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO application.cities(cityname, stateprovinceid, latestrecordedpopulation, lasteditedby)
    SELECT x."CityName", x."StateProvinceID", x."LatestRecordedPopulation", p_user_id
    FROM jsonb_to_recordset(p_cities::jsonb) AS x(
        "CityName"                 varchar(50),
        "StateProvinceID"          integer,
        "LatestRecordedPopulation" bigint
    )
    RETURNING cities.cityid;
END;
$$ LANGUAGE plpgsql;
