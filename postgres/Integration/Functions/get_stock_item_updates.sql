-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetStockItemUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_stock_item_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "WWI Stock Item ID"          integer,
    "Stock Item"                 varchar(100),
    "Color"                      varchar(20),
    "Selling Package"            varchar(50),
    "Buying Package"             varchar(50),
    "Brand"                      varchar(50),
    "Size"                       varchar(20),
    "Lead Time Days"             integer,
    "Quantity Per Outer"         integer,
    "Is Chiller Stock"           boolean,
    "Barcode"                    varchar(50),
    "Tax Rate"                   numeric(18,3),
    "Unit Price"                 numeric(18,2),
    "Recommended Retail Price"   numeric(18,2),
    "Typical Weight Per Unit"    numeric(18,3),
    "Photo"                      bytea,
    "Valid From"                 timestamp,
    "Valid To"                   timestamp
) AS $$
DECLARE
    rec RECORD;
    _end_of_time timestamp := '9999-12-31 23:59:59.9999999';
BEGIN
    DROP TABLE IF EXISTS stockitemchanges;
    CREATE TEMP TABLE stockitemchanges (
        "WWI Stock Item ID"          integer,
        "Stock Item"                 varchar(100),
        "Color"                      varchar(20),
        "Selling Package"            varchar(50),
        "Buying Package"             varchar(50),
        "Brand"                      varchar(50),
        "Size"                       varchar(20),
        "Lead Time Days"             integer,
        "Quantity Per Outer"         integer,
        "Is Chiller Stock"           boolean,
        "Barcode"                    varchar(50),
        "Tax Rate"                   numeric(18,3),
        "Unit Price"                 numeric(18,2),
        "Recommended Retail Price"   numeric(18,2),
        "Typical Weight Per Unit"    numeric(18,3),
        "Photo"                      bytea,
        "Valid From"                 timestamp,
        "Valid To"                   timestamp
    );

    -- Cursor converted to FOR loop: UNION ALL of archive + current StockItem changes ordered by ValidFrom
    FOR rec IN
        SELECT c.StockItemID,
               c.ValidFrom
        FROM warehouse.stockitems_archive AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        UNION ALL
        SELECT c.StockItemID,
               c.ValidFrom
        FROM warehouse.stockitems AS c
        WHERE c.ValidFrom > p_last_cutoff
          AND c.ValidFrom <= p_new_cutoff
        ORDER BY ValidFrom
    LOOP
        -- TODO: FOR SYSTEM_TIME AS OF rec.validfrom (4 temporal tables: StockItems, PackageTypes x2, Colors)
        -- not supported natively in PostgreSQL.
        -- Approximation: for each temporal table, union archive rows valid at rec.validfrom with the
        -- current-table fallback. DISTINCT ON (PK) ORDER BY PK, ValidFrom DESC ensures one row per key.
        INSERT INTO stockitemchanges (
            "WWI Stock Item ID", "Stock Item", "Color", "Selling Package", "Buying Package",
            "Brand", "Size", "Lead Time Days", "Quantity Per Outer", "Is Chiller Stock",
            "Barcode", "Tax Rate", "Unit Price", "Recommended Retail Price",
            "Typical Weight Per Unit", "Photo", "Valid From", "Valid To"
        )
        SELECT si.StockItemID, si.StockItemName, c.ColorName, spt.PackageTypeName,
               bpt.PackageTypeName, si.Brand, si.Size, si.LeadTimeDays, si.QuantityPerOuter,
               si.IsChillerStock, si.Barcode, si.TaxRate, si.UnitPrice, si.RecommendedRetailPrice,
               si.TypicalWeightPerUnit, si.Photo, si.ValidFrom, si.ValidTo
        FROM (
            -- StockItems snapshot at rec.validfrom, filtered to the changed item
            SELECT StockItemID, StockItemName, ColorID, UnitPackageID, OuterPackageID,
                   Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock,
                   Barcode, TaxRate, UnitPrice, RecommendedRetailPrice,
                   TypicalWeightPerUnit, Photo, ValidFrom, ValidTo
            FROM warehouse.stockitems_archive
            WHERE StockItemID = rec.stockitemid
              AND ValidFrom <= rec.validfrom
              AND ValidTo > rec.validfrom
            UNION ALL
            SELECT StockItemID, StockItemName, ColorID, UnitPackageID, OuterPackageID,
                   Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock,
                   Barcode, TaxRate, UnitPrice, RecommendedRetailPrice,
                   TypicalWeightPerUnit, Photo, ValidFrom,
                   CAST('9999-12-31 23:59:59.9999999' AS timestamp) AS ValidTo
            FROM warehouse.stockitems
            WHERE StockItemID = rec.stockitemid
              AND ValidFrom <= rec.validfrom
            ORDER BY ValidFrom DESC
            LIMIT 1
        ) AS si
        INNER JOIN (
            -- PackageTypes snapshot at rec.validfrom (selling/unit package)
            SELECT DISTINCT ON (PackageTypeID) PackageTypeID, PackageTypeName
            FROM (
                SELECT PackageTypeID, PackageTypeName, ValidFrom
                FROM warehouse.package_types_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT PackageTypeID, PackageTypeName, ValidFrom
                FROM warehouse.package_types
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY PackageTypeID, ValidFrom DESC
        ) AS spt ON si.UnitPackageID = spt.PackageTypeID
        INNER JOIN (
            -- PackageTypes snapshot at rec.validfrom (buying/outer package)
            SELECT DISTINCT ON (PackageTypeID) PackageTypeID, PackageTypeName
            FROM (
                SELECT PackageTypeID, PackageTypeName, ValidFrom
                FROM warehouse.package_types_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT PackageTypeID, PackageTypeName, ValidFrom
                FROM warehouse.package_types
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY PackageTypeID, ValidFrom DESC
        ) AS bpt ON si.OuterPackageID = bpt.PackageTypeID
        LEFT OUTER JOIN (
            -- Colors snapshot at rec.validfrom
            SELECT DISTINCT ON (ColorID) ColorID, ColorName
            FROM (
                SELECT ColorID, ColorName, ValidFrom
                FROM warehouse.colors_archive
                WHERE ValidFrom <= rec.validfrom AND ValidTo > rec.validfrom
                UNION ALL
                SELECT ColorID, ColorName, ValidFrom
                FROM warehouse.colors
                WHERE ValidFrom <= rec.validfrom
            ) AS combined
            ORDER BY ColorID, ValidFrom DESC
        ) AS c ON si.ColorID = c.ColorID;
    END LOOP;

    CREATE INDEX ix_stockitemchanges ON stockitemchanges ("WWI Stock Item ID", "Valid From");

    -- Update Valid To: min(Valid From) of a later row for the same stock item, or end-of-time
    UPDATE stockitemchanges AS cc
    SET "Valid To" = COALESCE(
        (SELECT MIN(cc2."Valid From")
         FROM stockitemchanges AS cc2
         WHERE cc2."WWI Stock Item ID" = cc."WWI Stock Item ID"
           AND cc2."Valid From" > cc."Valid From"),
        _end_of_time
    );

    -- ISNULL(Color/Brand/Size/Barcode, N'N/A') -> COALESCE(col, 'N/A')
    RETURN QUERY
    SELECT cc."WWI Stock Item ID",
           cc."Stock Item",
           COALESCE(cc."Color", 'N/A'),
           cc."Selling Package",
           cc."Buying Package",
           COALESCE(cc."Brand", 'N/A'),
           COALESCE(cc."Size", 'N/A'),
           cc."Lead Time Days",
           cc."Quantity Per Outer",
           cc."Is Chiller Stock",
           COALESCE(cc."Barcode", 'N/A'),
           cc."Tax Rate",
           cc."Unit Price",
           cc."Recommended Retail Price",
           cc."Typical Weight Per Unit",
           cc."Photo",
           cc."Valid From",
           cc."Valid To"
    FROM stockitemchanges AS cc
    ORDER BY cc."Valid From";

    DROP TABLE IF EXISTS stockitemchanges;
END;
$$ LANGUAGE plpgsql;
-- Requires: CREATE EXTENSION IF NOT EXISTS postgis;  (warehouse.stockitems_archive may reference geography)
