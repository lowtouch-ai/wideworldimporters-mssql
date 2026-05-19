-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockItemUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

-- TODO: FOR SYSTEM_TIME AS OF not supported natively in PostgreSQL.
-- Rewritten using archive tables with ValidFrom/ValidTo range filtering.

CREATE OR REPLACE FUNCTION integration.get_stock_item_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "WWI Stock Item ID" integer,
    "Stock Item" varchar(100),
    "Color" varchar(20),
    "Selling Package" varchar(50),
    "Buying Package" varchar(50),
    "Brand" varchar(50),
    "Size" varchar(20),
    "Lead Time Days" integer,
    "Quantity Per Outer" integer,
    "Is Chiller Stock" boolean,
    "Barcode" varchar(50),
    "Tax Rate" numeric(18,3),
    "Unit Price" numeric(18,2),
    "Recommended Retail Price" numeric(18,2),
    "Typical Weight Per Unit" numeric(18,3),
    "Photo" bytea,
    "Valid From" timestamp(6),
    "Valid To" timestamp(6)
) AS $$
DECLARE
    _EndOfTime timestamp(6) := '9999-12-31 23:59:59.999999';
    _StockItemID integer;
    _ValidFrom timestamp(6);
BEGIN
    CREATE TEMP TABLE _stock_item_changes (
        "WWI Stock Item ID" integer,
        "Stock Item" varchar(100),
        "Color" varchar(20),
        "Selling Package" varchar(50),
        "Buying Package" varchar(50),
        "Brand" varchar(50),
        "Size" varchar(20),
        "Lead Time Days" integer,
        "Quantity Per Outer" integer,
        "Is Chiller Stock" boolean,
        "Barcode" varchar(50),
        "Tax Rate" numeric(18,3),
        "Unit Price" numeric(18,2),
        "Recommended Retail Price" numeric(18,2),
        "Typical Weight Per Unit" numeric(18,3),
        "Photo" bytea,
        "Valid From" timestamp(6),
        "Valid To" timestamp(6)
    ) ON COMMIT DROP;

    FOR _StockItemID, _ValidFrom IN
        SELECT c.StockItemID, c.ValidFrom
        FROM warehouse.stockitems_archive AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        UNION ALL
        SELECT c.StockItemID, c.ValidFrom
        FROM warehouse.stockitems AS c
        WHERE c.ValidFrom > p_LastCutoff AND c.ValidFrom <= p_NewCutoff
        ORDER BY ValidFrom
    LOOP
        INSERT INTO _stock_item_changes
        SELECT si.StockItemID, si.StockItemName, c.ColorName, spt.PackageTypeName,
               bpt.PackageTypeName, si.Brand, si.Size, si.LeadTimeDays, si.QuantityPerOuter,
               si.IsChillerStock, si.Barcode, si.TaxRate, si.UnitPrice, si.RecommendedRetailPrice,
               si.TypicalWeightPerUnit, si.Photo, si.ValidFrom, si.ValidTo
        FROM (
            SELECT * FROM warehouse.stockitems_archive
            WHERE StockItemID = _StockItemID
              AND ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM warehouse.stockitems
            WHERE StockItemID = _StockItemID
              AND ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS si
        JOIN (
            SELECT * FROM warehouse.packagetypes_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM warehouse.packagetypes
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS spt ON si.UnitPackageID = spt.PackageTypeID
        JOIN (
            SELECT * FROM warehouse.packagetypes_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM warehouse.packagetypes
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS bpt ON si.OuterPackageID = bpt.PackageTypeID
        LEFT JOIN (
            SELECT * FROM warehouse.colors_archive
            WHERE ValidFrom <= _ValidFrom AND (ValidTo > _ValidFrom OR ValidTo IS NULL)
            UNION ALL
            SELECT * FROM warehouse.colors
            WHERE ValidFrom <= _ValidFrom AND ValidTo > _ValidFrom
        ) AS c ON si.ColorID = c.ColorID;
    END LOOP;

    UPDATE _stock_item_changes AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From") FROM _stock_item_changes AS cc2
         WHERE cc2."WWI Stock Item ID" = cc."WWI Stock Item ID"
           AND cc2."Valid From" > cc."Valid From"),
        _EndOfTime
    );

    RETURN QUERY
    SELECT
        "WWI Stock Item ID",
        "Stock Item",
        COALESCE("Color", 'N/A'),
        "Selling Package",
        "Buying Package",
        COALESCE("Brand", 'N/A'),
        COALESCE("Size", 'N/A'),
        "Lead Time Days",
        "Quantity Per Outer",
        "Is Chiller Stock",
        COALESCE("Barcode", 'N/A'),
        "Tax Rate",
        "Unit Price",
        "Recommended Retail Price",
        "Typical Weight Per Unit",
        "Photo",
        "Valid From",
        "Valid To"
    FROM _stock_item_changes
    ORDER BY "Valid From";
END;
$$ LANGUAGE plpgsql;
