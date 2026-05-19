-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPaymentMethodUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_payment_method_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Payment Method ID" integer,
    "Payment Method" varchar(50),
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _PaymentMethodID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _payment_method_changes (
        "WWI Payment Method ID" integer,
        "Payment Method" varchar(50),
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    FOR _PaymentMethodID, _ValidFrom IN
        SELECT p.PaymentMethodID, p.ValidFrom
        FROM application.paymentmethods_archive AS p
        WHERE p.ValidFrom > p_LastCutoff AND p.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT p.PaymentMethodID, p.ValidFrom
        FROM application.paymentmethods AS p
        WHERE p.ValidFrom > p_LastCutoff AND p.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _payment_method_changes
        SELECT p.PaymentMethodID, p.PaymentMethodName, p.ValidFrom, p.ValidTo
        FROM (
            SELECT * FROM application.paymentmethods_archive
            WHERE PaymentMethodID = _PaymentMethodID
              AND ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.paymentmethods
            WHERE PaymentMethodID = _PaymentMethodID
              AND ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p;
    END LOOP;

    UPDATE _payment_method_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _payment_method_changes AS cc2
         WHERE cc2."WWI Payment Method ID" = cc."WWI Payment Method ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _payment_method_changes ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
