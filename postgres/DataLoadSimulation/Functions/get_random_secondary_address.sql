-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomSecondaryAddress.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_secondary_address(
) RETURNS varchar(20) AS $$
DECLARE
    v_sa varchar(20);
BEGIN
    WITH secondary_address(addr) AS (
        VALUES ('PO Box '), ('Suite '), ('Office '), ('Mail Stop '), ('Box '),
               ('Bin '), ('Room '),
               (''), (''), (''), (''), (''), (''), (''), (''), (''), (''), (''), (''), (''), ('')
    )
    SELECT addr INTO v_sa FROM secondary_address ORDER BY random() LIMIT 1;

    IF LENGTH(v_sa) > 0 THEN
        RETURN v_sa || CAST(floor(random() * 899)::integer AS varchar);
    ELSE
        RETURN '';
    END IF;
END;
$$ LANGUAGE plpgsql;
