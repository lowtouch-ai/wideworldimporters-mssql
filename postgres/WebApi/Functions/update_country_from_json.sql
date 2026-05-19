-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCountryFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_country_from_json(
    p_country    text,
    p_country_id integer,
    p_user_id    integer
) RETURNS void AS $$
BEGIN
    UPDATE application.countries
    SET countryname              = x."CountryName",
        formalname               = x."FormalName",
        isoalpha3code            = x."IsoAlpha3Code",
        isonumericcode           = x."IsoNumericCode",
        countrytype              = x."CountryType",
        latestrecordedpopulation = x."LatestRecordedPopulation",
        continent                = x."Continent",
        region                   = x."Region",
        subregion                = x."Subregion",
        lasteditedby             = p_user_id
    FROM jsonb_to_record(p_country::jsonb) AS x(
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
    WHERE countries.countryid = p_country_id;
END;
$$ LANGUAGE plpgsql;
