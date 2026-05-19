-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStateProvinceFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_state_province_from_json(
    p_state_province text,
    p_state_province_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.stateprovinces SET
        "StateProvinceCode" = json.state_province_code,
        "StateProvinceName" = json.state_province_name,
        "CountryID" = json.country_id,
        "SalesTerritory" = json.sales_territory,
        "LatestRecordedPopulation" = json.latest_recorded_population,
        "LastEditedBy" = p_user_id
    FROM jsonb_to_recordset(p_state_province::jsonb) AS json(
        state_province_code varchar(5),
        state_province_name varchar(50),
        country_id integer,
        sales_territory varchar(50),
        latest_recorded_population bigint
    )
    WHERE application.stateprovinces."StateProvinceID" = p_state_province_id;
END;
$$ LANGUAGE plpgsql;
