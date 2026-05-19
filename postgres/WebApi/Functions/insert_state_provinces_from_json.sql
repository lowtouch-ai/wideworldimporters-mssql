-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStateProvincesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_state_provinces_from_json(
    p_state_provinces text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO application.stateprovinces (
        StateProvinceCode, StateProvinceName, CountryID,
        SalesTerritory, LatestRecordedPopulation, LastEditedBy
    )
    SELECT x.StateProvinceCode, x.StateProvinceName, x.CountryID,
           x.SalesTerritory, x.LatestRecordedPopulation, p_user_id
    FROM jsonb_to_recordset(p_state_provinces::jsonb) AS x(
        StateProvinceCode varchar(5),
        StateProvinceName varchar(50),
        CountryID integer,
        SalesTerritory varchar(50),
        LatestRecordedPopulation bigint
    );
END;
$$ LANGUAGE plpgsql;
