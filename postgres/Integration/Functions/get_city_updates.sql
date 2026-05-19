-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCityUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten to use archive tables (e.g. application.cities_archive) with ValidFrom/ValidTo range WHERE clause.
-- The archive tables must exist with ValidFrom and ValidTo columns.

CREATE OR REPLACE FUNCTION integration.get_city_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI City ID" integer,
    "City" varchar(50),
    "State Province" varchar(50),
    "Country" varchar(50),
    "Continent" varchar(30),
    "Sales Territory" varchar(50),
    "Region" varchar(30),
    "Subregion" varchar(30),
    "Location" geography,
    "Latest Recorded Population" bigint,
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _InitialLoadDate date := '2020-01-01';
    _CountryID integer;
    _StateProvinceID integer;
    _CityID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _city_changes (
        "WWI City ID" integer,
        "City" varchar(50),
        "State Province" varchar(50),
        "Country" varchar(50),
        "Continent" varchar(30),
        "Sales Territory" varchar(50),
        "Region" varchar(30),
        "Subregion" varchar(30),
        "Location" geography,
        "Latest Recorded Population" bigint,
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    -- Country changes since last cutoff
    FOR _CountryID, _ValidFrom IN
        SELECT co.CountryID, co.ValidFrom
        FROM application.countries_archive AS co
        WHERE co.ValidFrom > p_LastCutoff
          AND co.ValidFrom <= p_NewCutoff
          AND co.ValidFrom <> _InitialLoadDate
        UNION ALL
        SELECT co.CountryID, co.ValidFrom
        FROM application.countries AS co
        WHERE co.ValidFrom > p_LastCutoff
          AND co.ValidFrom <= p_NewCutoff
          AND co.ValidFrom <> _InitialLoadDate
        ORDER BY ValidFrom
    LOOP
        -- TODO: FOR SYSTEM_TIME AS OF @ValidFrom → join archive + current with ValidFrom/ValidTo range
        INSERT INTO _city_changes
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion,
               c."Location", COALESCE(c.LatestRecordedPopulation, 0), _ValidFrom, NULL
        FROM (
            SELECT * FROM application.cities_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.cities
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM application.stateprovinces_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.stateprovinces
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        JOIN (
            SELECT * FROM application.countries_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.countries
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS co ON sp.CountryID = co.CountryID
        WHERE co.CountryID = _CountryID;
    END LOOP;

    -- StateProvince changes since last cutoff
    FOR _StateProvinceID, _ValidFrom IN
        SELECT sp.StateProvinceID, sp.ValidFrom
        FROM application.stateprovinces_archive AS sp
        WHERE sp.ValidFrom > p_LastCutoff
          AND sp.ValidFrom <= p_NewCutoff
          AND sp.ValidFrom <> _InitialLoadDate
        UNION ALL
        SELECT sp.StateProvinceID, sp.ValidFrom
        FROM application.stateprovinces AS sp
        WHERE sp.ValidFrom > p_LastCutoff
          AND sp.ValidFrom <= p_NewCutoff
          AND sp.ValidFrom <> _InitialLoadDate
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _city_changes
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion,
               c."Location", COALESCE(c.LatestRecordedPopulation, 0), _ValidFrom, NULL
        FROM (
            SELECT * FROM application.cities_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.cities
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM application.stateprovinces_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.stateprovinces
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        JOIN (
            SELECT * FROM application.countries_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.countries
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS co ON sp.CountryID = co.CountryID
        WHERE sp.StateProvinceID = _StateProvinceID;
    END LOOP;

    -- City changes (including initial load)
    FOR _CityID, _ValidFrom IN
        SELECT c.CityID, c.ValidFrom
        FROM application.cities_archive AS c
        WHERE c.ValidFrom > p_LastCutoff
          AND c.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT c.CityID, c.ValidFrom
        FROM application.cities AS c
        WHERE c.ValidFrom > p_LastCutoff
          AND c.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _city_changes
        SELECT c.CityID, c.CityName, sp.StateProvinceName, co.CountryName, co.Continent,
               sp.SalesTerritory, co.Region, co.Subregion,
               c."Location", COALESCE(c.LatestRecordedPopulation, 0), _ValidFrom, NULL
        FROM (
            SELECT * FROM application.cities_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.cities
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM application.stateprovinces_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.stateprovinces
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS sp ON c.StateProvinceID = sp.StateProvinceID
        JOIN (
            SELECT * FROM application.countries_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.countries
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS co ON sp.CountryID = co.CountryID
        WHERE c.CityID = _CityID;
    END LOOP;

    -- Compute Valid To: next Valid From for same city, or end of time
    UPDATE _city_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _city_changes AS cc2
         WHERE cc2."WWI City ID" = cc."WWI City ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _city_changes
    ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
