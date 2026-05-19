-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetTransactionTypeUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_transaction_type_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Transaction Type ID" integer,
    "Transaction Type"        varchar(50),
    "Valid From"              timestamp,
    "Valid To"                timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time timestamp := '9999-12-31 23:59:59.9999999';
BEGIN
    DROP TABLE IF EXISTS transactiontypechanges;
    CREATE TEMP TABLE transactiontypechanges (
        "WWI Transaction Type ID" integer,
        "Transaction Type"        varchar(50),
        "Valid From"              timestamp,
        "Valid To"                timestamp
    );

    -- Cursor converted to FOR loop: UNION ALL of archive + current changes ordered by ValidFrom
    FOR rec IN
        SELECT tt.TransactionTypeID,
               tt.ValidFrom
        FROM application.transaction_types_archive AS tt
        WHERE tt.ValidFrom > p_last_cutoff
          AND tt.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT tt.TransactionTypeID,
               tt.ValidFrom
        FROM application.transaction_types AS tt
        WHERE tt.ValidFrom > p_last_cutoff
          AND tt.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom not supported natively in PostgreSQL.
        -- Approximation: query archive for the version valid at rec.validfrom (ValidFrom <= ts AND ValidTo > ts),
        -- falling back to the current-table row if no archive match, taking the most recent version.
        INSERT INTO transactiontypechanges ("WWI Transaction Type ID", "Transaction Type", "Valid From", "Valid To")
        SELECT p.TransactionTypeID, p.TransactionTypeName, p.ValidFrom, p.ValidTo
        FROM (
            SELECT TransactionTypeID, TransactionTypeName, ValidFrom, ValidTo
            FROM application.transaction_types_archive
            WHERE TransactionTypeID = rec.transactiontypeid
              AND ValidFrom <= rec.validfrom
              AND ValidTo > rec.validfrom
            UNION ALL
            SELECT TransactionTypeID, TransactionTypeName, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM application.transaction_types
            WHERE TransactionTypeID = rec.transactiontypeid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS p;
    END LOOP;

    CREATE INDEX ix_transactiontypechanges ON transactiontypechanges ("WWI Transaction Type ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same transaction type, or end-of-time
    UPDATE transactiontypechanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM transactiontypechanges AS cc2
         WHERE cc2."WWI Transaction Type ID" = cc."WWI Transaction Type ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI Transaction Type ID", cc."Transaction Type", cc."Valid From", cc."Valid To"
    FROM transactiontypechanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS transactiontypechanges;
END;
$$ LANGUAGE plpgsql;
