-- Converted from: wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomPaymentDays.sql
CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_payment_days(
) RETURNS integer AS $$
DECLARE
    v_pd integer;
BEGIN
    v_pd := floor(random() * 8)::integer;

    RETURN CASE v_pd
        WHEN 0 THEN 30
        WHEN 1 THEN 45
        WHEN 2 THEN 60
        WHEN 3 THEN 90
        WHEN 4 THEN 180
        WHEN 5 THEN 30
        WHEN 6 THEN 45
        WHEN 7 THEN 30
        WHEN 8 THEN 45
        ELSE 30
    END;
END;
$$ LANGUAGE plpgsql;
