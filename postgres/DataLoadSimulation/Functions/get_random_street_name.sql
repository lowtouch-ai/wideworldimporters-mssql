-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStreetName.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_street_name(
) RETURNS varchar(20) AS $$
DECLARE
    v_name varchar(20);
BEGIN
    WITH street_names(street) AS (
        VALUES ('Elm'), ('Maple'), ('Oak'), ('Sugar'), ('Main'), ('Pine'), ('Spruce'),
               ('Aspen'), ('Birch'), ('Fir'), ('Hickory'), ('Walnut'), ('Willow'),
               ('Sycamore'), ('Tulip'), ('Rose'), ('Cotton'), ('Ash'), ('Lily'),
               ('Cherry'), ('Violet'),
               ('First'), ('Second'), ('Third'), ('Fourth'), ('Fifth'), ('Sixth'),
               ('Seventh'), ('Eighth'), ('Ninth'), ('Tenth'), ('Eleventh'), ('Twelfth'),
               ('Thirteenth'), ('Fourteenth'), ('Fifteenth'), ('Sixteenth'), ('Seventeenth'),
               ('Eighteenth'), ('Nineteenth'), ('Twentieth'),
               ('1st'), ('2nd'), ('3rd'), ('4th'), ('5th'), ('6th'), ('7th'), ('8th'),
               ('9th'), ('10th'), ('11th'), ('12th'), ('13th'), ('14th'), ('15th'),
               ('16th'), ('17th'), ('18th'), ('19th'), ('20th')
    )
    SELECT street INTO v_name FROM street_names ORDER BY random() LIMIT 1;

    RETURN v_name;
END;
$$ LANGUAGE plpgsql;
