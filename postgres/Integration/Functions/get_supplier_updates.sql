-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSupplierUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_supplier_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Supplier ID"    integer,
    "Supplier"           varchar(100),
    "Category"           varchar(50),
    "Primary Contact"    varchar(50),
    "Supplier Reference" varchar(20),
    "Payment Days"       integer,
    "Postal Code"        varchar(10),
    "Valid From"         timestamp,
    "Valid To"           timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time       timestamp := '9999-12-31 23:59:59.9999999';
    _initial_load_date date      := '2020-01-01';
BEGIN
    DROP TABLE IF EXISTS supplierchanges;
    CREATE TEMP TABLE supplierchanges (
        "WWI Supplier ID"    integer,
        "Supplier"           varchar(100),
        "Category"           varchar(50),
        "Primary Contact"    varchar(50),
        "Supplier Reference" varchar(20),
        "Payment Days"       integer,
        "Postal Code"        varchar(10),
        "Valid From"         timestamp,
        "Valid To"           timestamp
    );

    -- Cursor 1: SupplierCategoryChangeList — changes to supplier categories (excluding initial load date)
    -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom (3 temporal tables: Suppliers, SupplierCategories, People)
    -- not supported natively in PostgreSQL.
    -- Approximation: DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC over (archive UNION ALL current).
    FOR rec IN
        SELECT cc.SupplierCategoryID,
               cc.ValidFrom
        FROM purchasing.supplier_categories_archive AS cc
        WHERE cc.ValidFrom > p_last_cutoff
          AND cc.ValidFrom <= p_new_cutoff
          AND cc.ValidFrom::date <> _initial_load_date
        UNION ALL
        SELECT cc.SupplierCategoryID,
               cc.ValidFrom
        FROM purchasing.supplier_categories AS cc
        WHERE cc.ValidFrom > p_last_cutoff
          AND cc.ValidFrom <= p_new_cutoff
          AND cc.ValidFrom::date <> _initial_load_date
        ORDER BY ValidFrom
    LOOP
        INSERT INTO supplierchanges (
            "WWI Supplier ID", "Supplier", "Category", "Primary Contact", "Supplier Reference",
            "Payment Days", "Postal Code", "Valid From", "Valid To"
        )
        SELECT s.SupplierID, s.SupplierName, sc.SupplierCategoryName, p.FullName,
               s.SupplierReference, s.PaymentDays, s.DeliveryPostalCode, s.ValidFrom, s.ValidTo
        FROM (
            -- Suppliers snapshot at rec.validfrom (all suppliers for this category)
            SELECT DISTINCT ON (SupplierID)
                   SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
                   SupplierReference, PaymentDays, DeliveryPostalCode, ValidFrom, ValidTo
            FROM (
                SELECT SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
                       SupplierReference, PaymentDays, DeliveryPostalCode, ValidFrom, ValidTo
                FROM purchasing.suppliers_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
                       SupplierReference, PaymentDays, DeliveryPostalCode, ValidFrom,
                       CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
                FROM purchasing.suppliers
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY SupplierID, ValidFrom DESC
        ) AS s
        INNER JOIN (
            -- SupplierCategories snapshot at rec.validfrom
            SELECT DISTINCT ON (SupplierCategoryID) SupplierCategoryID, SupplierCategoryName
            FROM (
                SELECT SupplierCategoryID, SupplierCategoryName, ValidFrom
                FROM purchasing.supplier_categories_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT SupplierCategoryID, SupplierCategoryName, ValidFrom
                FROM purchasing.supplier_categories
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY SupplierCategoryID, ValidFrom DESC
        ) AS sc ON s.SupplierCategoryID = sc.SupplierCategoryID
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
        ) AS p ON s.PrimaryContactPersonID = p.PersonID
        WHERE sc.SupplierCategoryID = rec.suppliercategoryid;
    END LOOP;

    -- Cursor 2: SupplierChangeList — direct supplier changes (including initial load)
    FOR rec IN
        SELECT c.SupplierID,
               c.ValidFrom
        FROM purchasing.suppliers_archive AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT c.SupplierID,
               c.ValidFrom
        FROM purchasing.suppliers AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO supplierchanges (
            "WWI Supplier ID", "Supplier", "Category", "Primary Contact", "Supplier Reference",
            "Payment Days", "Postal Code", "Valid From", "Valid To"
        )
        SELECT s.SupplierID, s.SupplierName, sc.SupplierCategoryName, p.FullName,
               s.SupplierReference, s.PaymentDays, s.DeliveryPostalCode, s.ValidFrom, s.ValidTo
        FROM (
            -- Suppliers snapshot at rec.validfrom, filtered to this supplier
            SELECT SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
                   SupplierReference, PaymentDays, DeliveryPostalCode, ValidFrom, ValidTo
            FROM purchasing.suppliers_archive
            WHERE SupplierID = rec.supplierid
              AND ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
            UNION ALL
            SELECT SupplierID, SupplierName, SupplierCategoryID, PrimaryContactPersonID,
                   SupplierReference, PaymentDays, DeliveryPostalCode, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM purchasing.suppliers
            WHERE SupplierID = rec.supplierid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS s
        INNER JOIN (
            SELECT DISTINCT ON (SupplierCategoryID) SupplierCategoryID, SupplierCategoryName
            FROM (
                SELECT SupplierCategoryID, SupplierCategoryName, ValidFrom
                FROM purchasing.supplier_categories_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT SupplierCategoryID, SupplierCategoryName, ValidFrom
                FROM purchasing.supplier_categories
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY SupplierCategoryID, ValidFrom DESC
        ) AS sc ON s.SupplierCategoryID = sc.SupplierCategoryID
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
        ) AS p ON s.PrimaryContactPersonID = p.PersonID
        WHERE s.SupplierID = rec.supplierid;
    END LOOP;

    CREATE INDEX ix_supplierchanges ON supplierchanges ("WWI Supplier ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same supplier, or end-of-time
    UPDATE supplierchanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM supplierchanges AS cc2
         WHERE cc2."WWI Supplier ID" = cc."WWI Supplier ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    RETURN QUERY
    SELECT cc."WWI Supplier ID", cc."Supplier", cc."Category", cc."Primary Contact",
           cc."Supplier Reference", cc."Payment Days", cc."Postal Code",
           cc."Valid From", cc."Valid To"
    FROM supplierchanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS supplierchanges;
END;
$$ LANGUAGE plpgsql;
