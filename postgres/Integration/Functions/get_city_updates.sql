-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCityUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_city_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI City ID"                integer,
    "City"                       varchar(50),
    "State Province"             varchar(50),
    "Country"                    varchar(50),
    "Continent"                  varchar(30),
    "Sales Territory"            varchar(50),
    "Region"                     varchar(30),
    "Subregion"                  varchar(30),
    "Location"                   geography,
    "Latest Recorded Population" bigint,
    "Valid From"                 timestamp,
    "Valid To"                   timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time       timestamp := '9999-12-31 23:59:59.9999999';
    _initial_load_date date      := '2020-01-01';
BEGIN
    DROP TABLE IF EXISTS citychanges;
    CREATE TEMP TABLE citychanges (
        "WWI City ID"                integer,
        "City"                       varchar(50),
        "State Province"             varchar(50),
        "Country"                    varchar(50),
        "Continent"                  varchar(30),
        "Sales Territory"            varchar(50),
        "Region"                     varchar(30),
        "Subregion"                  varchar(30),
        "Location"                   geography,
        "Latest Recorded Population" bigint,
        "Valid From"                 timestamp,
        "Valid To"                   timestamp
    );

    -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom (3 temporal tables: Cities, StateProvinces, Countries)
    -- not supported natively in PostgreSQL.
    -- Approximation: DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC over (archive UNION ALL current).

    -- Cursor 1: CountryChangeList — country changes since initial load (excluding initial load date)
    FOR rec IN
        SELECT co.CountryID,
               co.ValidFrom
        FROM application.countries_archive AS co
        WHERE co.ValidFrom > p_last_cutoff
          AND co.ValidFrom <= p_new_cutoff
          AND co.ValidFrom::date <> _initial_load_date
        UNION ALL
        SELECT co.CountryID,
               co.ValidFrom
        FROM application.countries AS co
        WHERE co.ValidFrom > p_last_cutoff
          AND co.ValidFrom <= p_new_cutoff
          AND co.ValidFrom::date <> _initial_load_date
        ORDER BY ValidFrom
    LOOP
        INSERT INTO citychanges (
            "WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory",
            "Region", "Subregion", "Location", "Latest Recorded Population", "Valid From", "Valid To"
        )
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion, c.Location,
               COALESCE(c.LatestRecordedPopulation, 0), rec.validfrom, NULL
        FROM (
            -- Cities snapshot at rec.validfrom (all cities)
            SELECT DISTINCT ON (CityID)
                   CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
            FROM (
                SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
                FROM application.cities_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
                FROM application.cities
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CityID, ValidFrom DESC
        ) AS c
        INNER JOIN (
            -- StateProvinces snapshot at rec.validfrom (all state provinces)
            SELECT DISTINCT ON (StateProvinceID)
                   StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
            FROM (
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY StateProvinceID, ValidFrom DESC
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        INNER JOIN (
            -- Countries snapshot at rec.validfrom
            SELECT DISTINCT ON (CountryID)
                   CountryID, CountryName, Continent, Region, Subregion, ValidFrom
            FROM (
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CountryID, ValidFrom DESC
        ) AS co ON sp.CountryID = co.CountryID
        WHERE co.CountryID = rec.countryid;
    END LOOP;

    -- Cursor 2: StateProvinceChangeList — state/province changes since initial load (excluding initial load date)
    FOR rec IN
        SELECT sp.StateProvinceID,
               sp.ValidFrom
        FROM application.state_provinces_archive AS sp
        WHERE sp.ValidFrom > p_last_cutoff
          AND sp.ValidFrom <= p_new_cutoff
          AND sp.ValidFrom::date <> _initial_load_date
        UNION ALL
        SELECT sp.StateProvinceID,
               sp.ValidFrom
        FROM application.state_provinces AS sp
        WHERE sp.ValidFrom > p_last_cutoff
          AND sp.ValidFrom <= p_new_cutoff
          AND sp.ValidFrom::date <> _initial_load_date
        ORDER BY ValidFrom
    LOOP
        INSERT INTO citychanges (
            "WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory",
            "Region", "Subregion", "Location", "Latest Recorded Population", "Valid From", "Valid To"
        )
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion, c.Location,
               COALESCE(c.LatestRecordedPopulation, 0), rec.validfrom, NULL
        FROM (
            -- Cities snapshot at rec.validfrom (all cities in this state/province)
            SELECT DISTINCT ON (CityID)
                   CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
            FROM (
                SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
                FROM application.cities_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
                FROM application.cities
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CityID, ValidFrom DESC
        ) AS c
        INNER JOIN (
            -- StateProvinces snapshot at rec.validfrom
            SELECT DISTINCT ON (StateProvinceID)
                   StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
            FROM (
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY StateProvinceID, ValidFrom DESC
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        INNER JOIN (
            -- Countries snapshot at rec.validfrom
            SELECT DISTINCT ON (CountryID)
                   CountryID, CountryName, Continent, Region, Subregion, ValidFrom
            FROM (
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CountryID, ValidFrom DESC
        ) AS co ON sp.CountryID = co.CountryID
        WHERE sp.StateProvinceID = rec.stateprovinceid;
    END LOOP;

    -- Cursor 3: CityChangeList — direct city changes (including initial load)
    FOR rec IN
        SELECT c.CityID,
               c.ValidFrom
        FROM application.cities_archive AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT c.CityID,
               c.ValidFrom
        FROM application.cities AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO citychanges (
            "WWI City ID", "City", "State Province", "Country", "Continent", "Sales Territory",
            "Region", "Subregion", "Location", "Latest Recorded Population", "Valid From", "Valid To"
        )
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion, c.Location,
               COALESCE(c.LatestRecordedPopulation, 0), rec.validfrom, NULL
        FROM (
            -- Cities snapshot at rec.validfrom, filtered to this specific city
            SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
            FROM application.cities_archive
            WHERE CityID = rec.cityid
              AND ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
            UNION ALL
            SELECT CityID, CityName, StateProvinceID, Location, LatestRecordedPopulation, ValidFrom
            FROM application.cities
            WHERE CityID = rec.cityid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS c
        INNER JOIN (
            SELECT DISTINCT ON (StateProvinceID)
                   StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
            FROM (
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT StateProvinceID, StateProvinceName, CountryID, SalesTerritory, ValidFrom
                FROM application.state_provinces
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY StateProvinceID, ValidFrom DESC
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        INNER JOIN (
            SELECT DISTINCT ON (CountryID)
                   CountryID, CountryName, Continent, Region, Subregion, ValidFrom
            FROM (
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CountryID, CountryName, Continent, Region, Subregion, ValidFrom
                FROM application.countries
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CountryID, ValidFrom DESC
        ) AS co ON sp.CountryID = co.CountryID
        WHERE c.CityID = rec.cityid;
    END LOOP;

    CREATE INDEX ix_citychanges ON citychanges ("WWI City ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same city, or end-of-time
    UPDATE citychanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM citychanges AS cc2
         WHERE cc2."WWI City ID" = cc."WWI City ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI City ID", cc."City", cc."State Province", cc."Country", cc."Continent",
           cc."Sales Territory", cc."Region", cc."Subregion", cc."Location",
           cc."Latest Recorded Population", cc."Valid From", cc."Valid To"
    FROM citychanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS citychanges;
END;
$$ LANGUAGE plpgsql;
-- Requires: CREATE EXTENSION IF NOT EXISTS postgis;  (citychanges."Location" is geography)
