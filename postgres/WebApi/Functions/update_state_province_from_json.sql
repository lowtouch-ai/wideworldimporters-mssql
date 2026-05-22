-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStateProvinceFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_state_province_from_json(
    p_state_province text,
    p_state_province_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.stateprovinces SET
        StateProvinceCode        = COALESCE(json."StateProvinceCode", application.stateprovinces.StateProvinceCode),
        StateProvinceName        = COALESCE(json."StateProvinceName", application.stateprovinces.StateProvinceName),
        CountryID                = COALESCE(json."CountryID",         application.stateprovinces.CountryID),
        SalesTerritory           = COALESCE(json."SalesTerritory",    application.stateprovinces.SalesTerritory),
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        LastEditedBy             = p_user_id
    FROM jsonb_to_record(p_state_province::jsonb) AS json(
        "StateProvinceCode"        varchar(5),
        "StateProvinceName"        varchar(50),
        "CountryID"                integer,
        "SalesTerritory"           varchar(50),
        "LatestRecordedPopulation" bigint
    )
    WHERE StateProvinceID = p_state_province_id;
END;
$$ LANGUAGE plpgsql;
