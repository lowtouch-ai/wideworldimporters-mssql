-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockItemsFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_stock_items_from_json(
    p_stock_items text,
    p_user_id     integer
) RETURNS TABLE(stockitemid integer) AS $$
BEGIN
    RETURN QUERY
    INSERT INTO warehouse.stockitems(
        stockitemname, supplierid, colorid, unitpackageid, outerpackageid,
        brand, size, leadtimedays, quantityperouter, ischillerstock,
        barcode, taxrate, unitprice, recommendedretailprice, typicalweightperunit,
        marketingcomments, internalcomments,
        -- TODO: Photo is varbinary(MAX) in MSSQL; pass base64-encoded string and decode here
        photo,
        customfields, lasteditedby
    )
    SELECT
        x."StockItemName", x."SupplierID", x."ColorID", x."UnitPackageID", x."OuterPackageID",
        x."Brand", x."Size", x."LeadTimeDays", x."QuantityPerOuter", x."IsChillerStock",
        x."Barcode", x."TaxRate", x."UnitPrice", x."RecommendedRetailPrice", x."TypicalWeightPerUnit",
        x."MarketingComments", x."InternalComments",
        CASE WHEN x."Photo" IS NOT NULL THEN decode(x."Photo", 'base64') ELSE NULL END,
        x."CustomFields", p_user_id
    FROM jsonb_to_recordset(p_stock_items::jsonb) AS x(
        "StockItemName"          varchar(100),
        "SupplierID"             integer,
        "ColorID"                integer,
        "UnitPackageID"          integer,
        "OuterPackageID"         integer,
        "Brand"                  varchar(50),
        "Size"                   varchar(20),
        "LeadTimeDays"           integer,
        "QuantityPerOuter"       integer,
        "IsChillerStock"         boolean,
        "Barcode"                varchar(50),
        "TaxRate"                numeric(18,3),
        "UnitPrice"              numeric(18,2),
        "RecommendedRetailPrice" numeric(18,2),
        "TypicalWeightPerUnit"   numeric(18,3),
        "MarketingComments"      text,
        "InternalComments"       text,
        "Photo"                  text,
        "CustomFields"           text
    )
    RETURNING stockitems.stockitemid;
END;
$$ LANGUAGE plpgsql;
