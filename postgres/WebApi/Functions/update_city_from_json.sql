-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCityFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_city_from_json(
    p_city    text,
    p_city_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.cities
    SET cityname                 = x."CityName",
        stateprovinceid          = x."StateProvinceID",
        latestrecordedpopulation = x."LatestRecordedPopulation",
        lasteditedby             = p_user_id
    FROM jsonb_to_record(p_city::jsonb) AS x(
        "CityName"                 varchar(50),
        "StateProvinceID"          integer,
        "LatestRecordedPopulation" bigint
    )
    WHERE cities.cityid = p_city_id;
END;
$$ LANGUAGE plpgsql;
