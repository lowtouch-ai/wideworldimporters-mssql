-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPaymentMethodUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_payment_method_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Payment Method ID" integer,
    "Payment Method"        varchar(50),
    "Valid From"            timestamp,
    "Valid To"              timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time timestamp := '9999-12-31 23:59:59.9999999';
BEGIN
    DROP TABLE IF EXISTS paymentmethodchanges;
    CREATE TEMP TABLE paymentmethodchanges (
        "WWI Payment Method ID" integer,
        "Payment Method"        varchar(50),
        "Valid From"            timestamp,
        "Valid To"              timestamp
    );

    -- Cursor converted to FOR loop: UNION ALL of archive + current changes ordered by ValidFrom
    FOR rec IN
        SELECT p.PaymentMethodID,
               p.ValidFrom
        FROM application.payment_methods_archive AS p
        WHERE p.ValidFrom > p_last_cutoff
          AND p.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT p.PaymentMethodID,
               p.ValidFrom
        FROM application.payment_methods AS p
        WHERE p.ValidFrom > p_last_cutoff
          AND p.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom not supported natively in PostgreSQL.
        -- Approximation: query archive for the version valid at rec.validfrom (ValidFrom <= ts AND ValidTo > ts),
        -- falling back to the current-table row if no archive match, taking the most recent version.
        INSERT INTO paymentmethodchanges ("WWI Payment Method ID", "Payment Method", "Valid From", "Valid To")
        SELECT p.PaymentMethodID, p.PaymentMethodName, p.ValidFrom, p.ValidTo
        FROM (
            SELECT PaymentMethodID, PaymentMethodName, ValidFrom, ValidTo
            FROM application.payment_methods_archive
            WHERE PaymentMethodID = rec.paymentmethodid
              AND ValidFrom <= rec.validfrom
              AND ValidTo > rec.validfrom
            UNION ALL
            SELECT PaymentMethodID, PaymentMethodName, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM application.payment_methods
            WHERE PaymentMethodID = rec.paymentmethodid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS p;
    END LOOP;

    CREATE INDEX ix_paymentmethodchanges ON paymentmethodchanges ("WWI Payment Method ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same payment method, or end-of-time
    UPDATE paymentmethodchanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM paymentmethodchanges AS cc2
         WHERE cc2."WWI Payment Method ID" = cc."WWI Payment Method ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI Payment Method ID", cc."Payment Method", cc."Valid From", cc."Valid To"
    FROM paymentmethodchanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS paymentmethodchanges;
END;
$$ LANGUAGE plpgsql;
