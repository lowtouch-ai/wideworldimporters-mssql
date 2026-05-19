-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCustomerUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_customer_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Customer ID" integer,
    "Customer" varchar(100),
    "Bill To Customer" varchar(100),
    "Category" varchar(50),
    "Buying Group" varchar(50),
    "Primary Contact" varchar(50),
    "Postal Code" varchar(10),
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _InitialLoadDate date := '2020-01-01';
    _BuyingGroupID integer;
    _CustomerCategoryID integer;
    _CustomerID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _customer_changes (
        "WWI Customer ID" integer,
        "Customer" varchar(100),
        "Bill To Customer" varchar(100),
        "Category" varchar(50),
        "Buying Group" varchar(50),
        "Primary Contact" varchar(50),
        "Postal Code" varchar(10),
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    -- Buying group changes
    FOR _BuyingGroupID, _ValidFrom IN
        SELECT bg.BuyingGroupID, bg.ValidFrom
        FROM sales.buyinggroups_archive AS bg
        WHERE bg.ValidFrom > p_LastCutoff AND bg.ValidFrom <= p_NewCutoff AND bg.ValidFrom <> _InitialLoadDate
        UNION ALL
        SELECT bg.BuyingGroupID, bg.ValidFrom
        FROM sales.buyinggroups AS bg
        WHERE bg.ValidFrom > p_LastCutoff AND bg.ValidFrom <= p_NewCutoff AND bg.ValidFrom <> _InitialLoadDate
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _customer_changes
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM sales.customercategories_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customercategories WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        JOIN (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        JOIN (
            SELECT * FROM application.people_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM application.people WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            SELECT * FROM sales.buyinggroups_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.buyinggroups WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE c.BuyingGroupID = _BuyingGroupID;
    END LOOP;

    -- Customer category changes
    FOR _CustomerCategoryID, _ValidFrom IN
        SELECT cc.CustomerCategoryID, cc.ValidFrom
        FROM sales.customercategories_archive AS cc
        WHERE cc.ValidFrom > p_LastCutoff AND cc.ValidFrom <= p_NewCutoff AND cc.ValidFrom <> _InitialLoadDate
        UNION ALL
        SELECT cc.CustomerCategoryID, cc.ValidFrom
        FROM sales.customercategories AS cc
        WHERE cc.ValidFrom > p_LastCutoff AND cc.ValidFrom <= p_NewCutoff AND cc.ValidFrom <> _InitialLoadDate
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _customer_changes
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM sales.customercategories_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customercategories WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        JOIN (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        JOIN (
            SELECT * FROM application.people_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM application.people WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            SELECT * FROM sales.buyinggroups_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.buyinggroups WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE cc.CustomerCategoryID = _CustomerCategoryID;
    END LOOP;

    -- Customer changes (including initial load)
    FOR _CustomerID, _ValidFrom IN
        SELECT c.CustomerID, c.ValidFrom
        FROM sales.customers_archive AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT c.CustomerID, c.ValidFrom
        FROM sales.customers AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _customer_changes
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c
        JOIN (
            SELECT * FROM sales.customercategories_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customercategories WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        JOIN (
            SELECT * FROM sales.customers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.customers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        JOIN (
            SELECT * FROM application.people_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM application.people WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            SELECT * FROM sales.buyinggroups_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM sales.buyinggroups WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE c.CustomerID = _CustomerID;
    END LOOP;

    UPDATE _customer_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _customer_changes AS cc2
         WHERE cc2."WWI Customer ID" = cc."WWI Customer ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _customer_changes ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
