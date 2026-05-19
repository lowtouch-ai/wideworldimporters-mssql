-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionTypeUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_transaction_type_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Transaction Type ID" integer,
    "Transaction Type" varchar(50),
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _TransactionTypeID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _transaction_type_changes (
        "WWI Transaction Type ID" integer,
        "Transaction Type" varchar(50),
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    FOR _TransactionTypeID, _ValidFrom IN
        SELECT tt.TransactionTypeID, tt.ValidFrom
        FROM application.transactiontypes_archive AS tt
        WHERE tt.ValidFrom > p_LastCutoff AND tt.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT tt.TransactionTypeID, tt.ValidFrom
        FROM application.transactiontypes AS tt
        WHERE tt.ValidFrom > p_LastCutoff AND tt.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _transaction_type_changes
        SELECT p.TransactionTypeID, p.TransactionTypeName, p.ValidFrom, p.ValidTo
        FROM (
            SELECT * FROM application.transactiontypes_archive
            WHERE TransactionTypeID = _TransactionTypeID
              AND ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM application.transactiontypes
            WHERE TransactionTypeID = _TransactionTypeID
              AND ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p;
    END LOOP;

    UPDATE _transaction_type_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _transaction_type_changes AS cc2
         WHERE cc2."WWI Transaction Type ID" = cc."WWI Transaction Type ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _transaction_type_changes ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
