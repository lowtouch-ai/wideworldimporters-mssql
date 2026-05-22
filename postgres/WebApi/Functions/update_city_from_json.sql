-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCityFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_city_from_json(
    p_city text,
    p_city_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.cities SET
        CityName                 = COALESCE(json."CityName",        application.cities.CityName),
        StateProvinceID          = COALESCE(json."StateProvinceID", application.cities.StateProvinceID),
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        LastEditedBy             = p_user_id
    FROM jsonb_to_record(p_city::jsonb) AS json(
        "CityName"                 varchar(50),
        "StateProvinceID"          integer,
        "LatestRecordedPopulation" bigint
    )
    WHERE CityID = p_city_id;
END;
$$ LANGUAGE plpgsql;
