-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStockItemsFromJson.sql
-- Note: Photo (varbinary(MAX)) mapped to bytea; CustomFields AS JSON mapped to jsonb.
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.insert_stock_items_from_json(
    p_stock_items text,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    INSERT INTO warehouse.stockitems (
        StockItemName, SupplierID, ColorID, UnitPackageID, OuterPackageID,
        Brand, Size, LeadTimeDays, QuantityPerOuter, IsChillerStock,
        Barcode, TaxRate, UnitPrice, RecommendedRetailPrice, TypicalWeightPerUnit,
        MarketingComments, InternalComments, Photo, CustomFields, LastEditedBy
    )
    SELECT
        x.StockItemName, x.SupplierID, x.ColorID, x.UnitPackageID, x.OuterPackageID,
        x.Brand, x.Size, x.LeadTimeDays, x.QuantityPerOuter, x.IsChillerStock,
        x.Barcode, x.TaxRate, x.UnitPrice, x.RecommendedRetailPrice, x.TypicalWeightPerUnit,
        x.MarketingComments, x.InternalComments, x.Photo, x.CustomFields, p_user_id
    FROM jsonb_to_recordset(p_stock_items::jsonb) AS x(
        StockItemName varchar(100),
        SupplierID integer,
        ColorID integer,
        UnitPackageID integer,
        OuterPackageID integer,
        Brand varchar(50),
        Size varchar(20),
        LeadTimeDays integer,
        QuantityPerOuter integer,
        IsChillerStock boolean,
        Barcode varchar(50),
        TaxRate numeric(18,3),
        UnitPrice numeric(18,2),
        RecommendedRetailPrice numeric(18,2),
        TypicalWeightPerUnit numeric(18,3),
        MarketingComments text,
        InternalComments text,
        Photo bytea,
        CustomFields jsonb
    );
END;
$$ LANGUAGE plpgsql;
