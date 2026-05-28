-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSupplierUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_supplier_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Supplier ID" integer,
    "Supplier" varchar(100),
    "Category" varchar(50),
    "Primary Contact" varchar(50),
    "Supplier Reference" varchar(20),
    "Payment Days" integer,
    "Postal Code" varchar(10),
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _InitialLoadDate date := '2020-01-01';
    _SupplierCategoryID integer;
    _SupplierID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _supplier_changes (
        "WWI Supplier ID" integer,
        "Supplier" varchar(100),
        "Category" varchar(50),
        "Primary Contact" varchar(50),
        "Supplier Reference" varchar(20),
        "Payment Days" integer,
        "Postal Code" varchar(10),
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    -- Supplier category changes
    FOR _SupplierCategoryID, _ValidFrom IN
        SELECT cc.SupplierCategoryID, cc.ValidFrom
        FROM purchasing.suppliercategories_archive AS cc
        WHERE cc.ValidFrom > p_LastCutoff AND cc.ValidFrom <= p_NewCutoff AND cc.ValidFrom <> _InitialLoadDate
        UNION ALL
        SELECT cc.SupplierCategoryID, cc.ValidFrom
        FROM purchasing.suppliercategories AS cc
        WHERE cc.ValidFrom > p_LastCutoff AND cc.ValidFrom <= p_NewCutoff AND cc.ValidFrom <> _InitialLoadDate
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _supplier_changes
        SELECT s.SupplierID, s.SupplierName, sc.SupplierCategoryName, p.FullName, s.SupplierReference,
               s.PaymentDays, s.DeliveryPostalCode, s.ValidFrom, s.ValidTo
        FROM (
            SELECT * FROM purchasing.suppliers_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM purchasing.suppliers WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS s
        JOIN (
            SELECT * FROM purchasing.suppliercategories_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM purchasing.suppliercategories WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS sc ON s.SupplierCategoryID = sc.SupplierCategoryID
        JOIN (
            SELECT * FROM application.people_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM application.people WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p ON s.PrimaryContactPersonID = p.PersonID
        WHERE sc.SupplierCategoryID = _SupplierCategoryID;
    END LOOP;

    -- Supplier changes (including initial load)
    FOR _SupplierID, _ValidFrom IN
        SELECT c.SupplierID, c.ValidFrom
        FROM purchasing.suppliers_archive AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT c.SupplierID, c.ValidFrom
        FROM purchasing.suppliers AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _supplier_changes
        SELECT s.SupplierID, s.SupplierName, sc.SupplierCategoryName, p.FullName, s.SupplierReference,
               s.PaymentDays, s.DeliveryPostalCode, s.ValidFrom, s.ValidTo
        FROM (
            SELECT * FROM purchasing.suppliers_archive WHERE SupplierID = _SupplierID AND ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM purchasing.suppliers WHERE SupplierID = _SupplierID AND ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS s
        JOIN (
            SELECT * FROM purchasing.suppliercategories_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM purchasing.suppliercategories WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS sc ON s.SupplierCategoryID = sc.SupplierCategoryID
        JOIN (
            SELECT * FROM application.people_archive WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL SELECT * FROM application.people WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS p ON s.PrimaryContactPersonID = p.PersonID;
    END LOOP;

    UPDATE _supplier_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _supplier_changes AS cc2
         WHERE cc2."WWI Supplier ID" = cc."WWI Supplier ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT * FROM _supplier_changes ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
