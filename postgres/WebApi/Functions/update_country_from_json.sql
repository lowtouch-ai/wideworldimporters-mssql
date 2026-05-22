-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCountryFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_country_from_json(
    p_country text,
    p_country_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE application.countries SET
        CountryName              = COALESCE(json."CountryName",              application.countries.CountryName),
        FormalName               = COALESCE(json."FormalName",               application.countries.FormalName),
        IsoAlpha3Code            = json."IsoAlpha3Code",
        IsoNumericCode           = json."IsoNumericCode",
        CountryType              = json."CountryType",
        LatestRecordedPopulation = json."LatestRecordedPopulation",
        Continent                = COALESCE(json."Continent",                application.countries.Continent),
        Region                   = COALESCE(json."Region",                   application.countries.Region),
        Subregion                = COALESCE(json."Subregion",                application.countries.Subregion),
        LastEditedBy             = p_user_id
    FROM jsonb_to_record(p_country::jsonb) AS json(
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
    WHERE CountryID = p_country_id;
END;
$$ LANGUAGE plpgsql;
