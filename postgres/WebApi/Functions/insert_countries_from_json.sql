-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCountriesFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_countries_from_json(
    p_countries text,
    p_user_id   integer
) RETURNS TABLE(countryid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO application.countries(
        countryname, formalname, isoalpha3code, isonumericcode,
        countrytype, latestrecordedpopulation, continent, region, subregion, lasteditedby
    )
    SELECT
        x."CountryName", x."FormalName", x."IsoAlpha3Code", x."IsoNumericCode",
        x."CountryType", x."LatestRecordedPopulation", x."Continent", x."Region", x."Subregion",
        p_user_id
    FROM jsonb_to_recordset(p_countries::jsonb) AS x(
        "CountryName"              varchar(60),
        "FormalName"               varchar(60),
        "IsoAlpha3Code"            varchar(3),
        "IsoNumericCode"           integer,
        "CountryType"              varchar(20),
        "LatestRecordedPopulation" bigint,
        "Continent"                varchar(30),
        "Region"                   varchar(30),
        "Subregion"                varchar(30)
    )
    RETURNING countries.countryid;
END;
$$ LANGUAGE plpgsql;
