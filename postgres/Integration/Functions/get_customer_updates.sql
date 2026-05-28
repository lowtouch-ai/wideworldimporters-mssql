-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetCustomerUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_customer_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Customer ID"   integer,
    "Customer"          varchar(100),
    "Bill To Customer"  varchar(100),
    "Category"          varchar(50),
    "Buying Group"      varchar(50),
    "Primary Contact"   varchar(50),
    "Postal Code"       varchar(10),
    "Valid From"        timestamp,
    "Valid To"          timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time       timestamp := '9999-12-31 23:59:59.9999999';
    _initial_load_date date      := '2020-01-01';
BEGIN
    DROP TABLE IF EXISTS customerchanges;
    CREATE TEMP TABLE customerchanges (
        "WWI Customer ID"   integer,
        "Customer"          varchar(100),
        "Bill To Customer"  varchar(100),
        "Category"          varchar(50),
        "Buying Group"      varchar(50),
        "Primary Contact"   varchar(50),
        "Postal Code"       varchar(10),
        "Valid From"        timestamp,
        "Valid To"          timestamp
    );

    -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom (5 temporal tables: Customers, CustomerCategories,
    -- Customers self-join for BillTo, People, BuyingGroups) not supported natively in PostgreSQL.
    -- Approximation: DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC over (archive UNION ALL current).

    -- Cursor 1: BuyingGroupChangeList — buying group changes since initial load (excluding initial load date)
    FOR rec IN
        SELECT bg.BuyingGroupID,
               bg.ValidFrom
        FROM sales.buying_groups_archive AS bg
        WHERE bg.ValidFrom > p_last_cutoff
          AND bg.ValidFrom <= p_new_cutoff
          AND bg.ValidFrom::date <> _initial_load_date
        UNION ALL
        SELECT bg.BuyingGroupID,
               bg.ValidFrom
        FROM sales.buying_groups AS bg
        WHERE bg.ValidFrom > p_last_cutoff
          AND bg.ValidFrom <= p_new_cutoff
          AND bg.ValidFrom::date <> _initial_load_date
        ORDER BY ValidFrom
    LOOP
        INSERT INTO customerchanges (
            "WWI Customer ID", "Customer", "Bill To Customer", "Category",
            "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To"
        )
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            -- Customers snapshot at rec.validfrom (all customers — filtered by BuyingGroupID after join)
            SELECT DISTINCT ON (CustomerID)
                   CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                   BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom, ValidTo
            FROM (
                SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                       BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom, ValidTo
                FROM sales.customers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                       BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom,
                       CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
                FROM sales.customers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerID, ValidFrom DESC
        ) AS c
        INNER JOIN (
            -- CustomerCategories snapshot at rec.validfrom
            SELECT DISTINCT ON (CustomerCategoryID) CustomerCategoryID, CustomerCategoryName
            FROM (
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerCategoryID, ValidFrom DESC
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        INNER JOIN (
            -- Customers self-join snapshot for BillTo
            SELECT DISTINCT ON (CustomerID) CustomerID, CustomerName
            FROM (
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerID, ValidFrom DESC
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        INNER JOIN (
            -- People snapshot at rec.validfrom
            SELECT DISTINCT ON (PersonID) PersonID, FullName
            FROM (
                SELECT PersonID, FullName, ValidFrom
                FROM application.people_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT PersonID, FullName, ValidFrom
                FROM application.people
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY PersonID, ValidFrom DESC
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            -- BuyingGroups snapshot at rec.validfrom
            SELECT DISTINCT ON (BuyingGroupID) BuyingGroupID, BuyingGroupName
            FROM (
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY BuyingGroupID, ValidFrom DESC
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE c.BuyingGroupID = rec.buyinggroupid;
    END LOOP;

    -- Cursor 2: CustomerCategoryChangeList — customer category changes since initial load (excluding initial load date)
    FOR rec IN
        SELECT cc.CustomerCategoryID,
               cc.ValidFrom
        FROM sales.customer_categories_archive AS cc
        WHERE cc.ValidFrom > p_last_cutoff
          AND cc.ValidFrom <= p_new_cutoff
          AND cc.ValidFrom::date <> _initial_load_date
        UNION ALL
        SELECT cc.CustomerCategoryID,
               cc.ValidFrom
        FROM sales.customer_categories AS cc
        WHERE cc.ValidFrom > p_last_cutoff
          AND cc.ValidFrom <= p_new_cutoff
          AND cc.ValidFrom::date <> _initial_load_date
        ORDER BY ValidFrom
    LOOP
        INSERT INTO customerchanges (
            "WWI Customer ID", "Customer", "Bill To Customer", "Category",
            "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To"
        )
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            SELECT DISTINCT ON (CustomerID)
                   CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                   BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom, ValidTo
            FROM (
                SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                       BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom, ValidTo
                FROM sales.customers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                       BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom,
                       CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
                FROM sales.customers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerID, ValidFrom DESC
        ) AS c
        INNER JOIN (
            SELECT DISTINCT ON (CustomerCategoryID) CustomerCategoryID, CustomerCategoryName
            FROM (
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerCategoryID, ValidFrom DESC
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        INNER JOIN (
            SELECT DISTINCT ON (CustomerID) CustomerID, CustomerName
            FROM (
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerID, ValidFrom DESC
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        INNER JOIN (
            SELECT DISTINCT ON (PersonID) PersonID, FullName
            FROM (
                SELECT PersonID, FullName, ValidFrom
                FROM application.people_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT PersonID, FullName, ValidFrom
                FROM application.people
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY PersonID, ValidFrom DESC
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            SELECT DISTINCT ON (BuyingGroupID) BuyingGroupID, BuyingGroupName
            FROM (
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY BuyingGroupID, ValidFrom DESC
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE cc.CustomerCategoryID = rec.customercategoryid;
    END LOOP;

    -- Cursor 3: CustomerChangeList — direct customer changes (including initial load)
    FOR rec IN
        SELECT c.CustomerID,
               c.ValidFrom
        FROM sales.customers_archive AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT c.CustomerID,
               c.ValidFrom
        FROM sales.customers AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO customerchanges (
            "WWI Customer ID", "Customer", "Bill To Customer", "Category",
            "Buying Group", "Primary Contact", "Postal Code", "Valid From", "Valid To"
        )
        SELECT c.CustomerID, c.CustomerName, bt.CustomerName, cc.CustomerCategoryName,
               bg.BuyingGroupName, p.FullName, c.DeliveryPostalCode,
               c.ValidFrom, c.ValidTo
        FROM (
            -- Customers snapshot filtered to this specific customer (LIMIT 1)
            SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                   BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom, ValidTo
            FROM sales.customers_archive
            WHERE CustomerID = rec.customerid
              AND ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
            UNION ALL
            SELECT CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID,
                   BuyingGroupID, PrimaryContactPersonID, DeliveryPostalCode, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM sales.customers
            WHERE CustomerID = rec.customerid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS c
        INNER JOIN (
            SELECT DISTINCT ON (CustomerCategoryID) CustomerCategoryID, CustomerCategoryName
            FROM (
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerCategoryID, CustomerCategoryName, ValidFrom
                FROM sales.customer_categories
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerCategoryID, ValidFrom DESC
        ) AS cc ON c.CustomerCategoryID = cc.CustomerCategoryID
        INNER JOIN (
            SELECT DISTINCT ON (CustomerID) CustomerID, CustomerName
            FROM (
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT CustomerID, CustomerName, ValidFrom
                FROM sales.customers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY CustomerID, ValidFrom DESC
        ) AS bt ON c.BillToCustomerID = bt.CustomerID
        INNER JOIN (
            SELECT DISTINCT ON (PersonID) PersonID, FullName
            FROM (
                SELECT PersonID, FullName, ValidFrom
                FROM application.people_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT PersonID, FullName, ValidFrom
                FROM application.people
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY PersonID, ValidFrom DESC
        ) AS p ON c.PrimaryContactPersonID = p.PersonID
        LEFT JOIN (
            SELECT DISTINCT ON (BuyingGroupID) BuyingGroupID, BuyingGroupName
            FROM (
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT BuyingGroupID, BuyingGroupName, ValidFrom
                FROM sales.buying_groups
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY BuyingGroupID, ValidFrom DESC
        ) AS bg ON c.BuyingGroupID = bg.BuyingGroupID
        WHERE c.CustomerID = rec.customerid;
    END LOOP;

    CREATE INDEX ix_customerchanges ON customerchanges ("WWI Customer ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same customer, or end-of-time
    UPDATE customerchanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM customerchanges AS cc2
         WHERE cc2."WWI Customer ID" = cc."WWI Customer ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI Customer ID", cc."Customer", cc."Bill To Customer", cc."Category",
           cc."Buying Group", cc."Primary Contact", cc."Postal Code",
           cc."Valid From", cc."Valid To"
    FROM customerchanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS customerchanges;
END;
$$ LANGUAGE plpgsql;
