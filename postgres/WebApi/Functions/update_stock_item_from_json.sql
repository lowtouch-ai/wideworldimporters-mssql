-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockItemFromJson.sql
-- Note: Photo (varbinary(MAX)) mapped to bytea; CustomFields AS JSON mapped to jsonb.
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_stock_item_from_json(
    p_stock_item text,
    p_stock_item_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.stockitems SET
        StockItemName = COALESCE(json.StockItemName, warehouse.stockitems.StockItemName),
        SupplierID = COALESCE(json.SupplierID, warehouse.stockitems.SupplierID),
        ColorID = json.ColorID,
        UnitPackageID = COALESCE(json.UnitPackageID, warehouse.stockitems.UnitPackageID),
        OuterPackageID = COALESCE(json.OuterPackageID, warehouse.stockitems.OuterPackageID),
        Brand = json.Brand,
        Size = json.Size,
        LeadTimeDays = COALESCE(json.LeadTimeDays, warehouse.stockitems.LeadTimeDays),
        QuantityPerOuter = COALESCE(json.QuantityPerOuter, warehouse.stockitems.QuantityPerOuter),
        IsChillerStock = COALESCE(json.IsChillerStock, warehouse.stockitems.IsChillerStock),
        Barcode = json.Barcode,
        TaxRate = COALESCE(json.TaxRate, warehouse.stockitems.TaxRate),
        UnitPrice = COALESCE(json.UnitPrice, warehouse.stockitems.UnitPrice),
        RecommendedRetailPrice = json.RecommendedRetailPrice,
        TypicalWeightPerUnit = COALESCE(json.TypicalWeightPerUnit, warehouse.stockitems.TypicalWeightPerUnit),
        MarketingComments = json.MarketingComments,
        InternalComments = json.InternalComments,
        Photo = json.Photo,
        CustomFields = json.CustomFields,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_stock_item::jsonb) AS json(
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
    )
    WHERE StockItemID = p_stock_item_id;
END;
$$ LANGUAGE plpgsql;
