CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.countries AS
SELECT CountryID, CountryName, FormalName, IsoAlpha3Code, IsoNumericCode, CountryType,
       LatestRecordedPopulation, Continent, Region, Subregion
FROM application.countries;
