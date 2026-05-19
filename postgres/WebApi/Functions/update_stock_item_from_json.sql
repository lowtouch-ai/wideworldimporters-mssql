-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStockItemFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_stock_item_from_json(
    p_stock_item text,
    p_stock_item_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE warehouse.stockitems SET
        "StockItemName"          = COALESCE(json.stock_item_name, warehouse.stockitems."StockItemName"),
        "SupplierID"             = COALESCE(json.supplier_id, warehouse.stockitems."SupplierID"),
        "ColorID"                = json.color_id,
        "UnitPackageID"          = COALESCE(json.unit_package_id, warehouse.stockitems."UnitPackageID"),
        "OuterPackageID"         = COALESCE(json.outer_package_id, warehouse.stockitems."OuterPackageID"),
        "Brand"                  = json.brand,
        "Size"                   = json.size,
        "LeadTimeDays"           = COALESCE(json.lead_time_days, warehouse.stockitems."LeadTimeDays"),
        "QuantityPerOuter"       = COALESCE(json.quantity_per_outer, warehouse.stockitems."QuantityPerOuter"),
        "IsChillerStock"         = COALESCE(json.is_chiller_stock, warehouse.stockitems."IsChillerStock"),
        "Barcode"                = json.barcode,
        "TaxRate"                = COALESCE(json.tax_rate, warehouse.stockitems."TaxRate"),
        "UnitPrice"              = COALESCE(json.unit_price, warehouse.stockitems."UnitPrice"),
        "RecommendedRetailPrice" = json.recommended_retail_price,
        "TypicalWeightPerUnit"   = COALESCE(json.typical_weight_per_unit, warehouse.stockitems."TypicalWeightPerUnit"),
        "MarketingComments"      = json.marketing_comments,
        "InternalComments"       = json.internal_comments,
        "Photo"                  = json.photo,
        "CustomFields"           = json.custom_fields,
        "LastEditedBy"           = p_user_id
    FROM jsonb_to_recordset(p_stock_item::jsonb) AS json(
        stock_item_name          varchar(100),
        supplier_id              integer,
        color_id                 integer,
        unit_package_id          integer,
        outer_package_id         integer,
        brand                    varchar(50),
        size                     varchar(20),
        lead_time_days           integer,
        quantity_per_outer       integer,
        is_chiller_stock         boolean,
        barcode                  varchar(50),
        tax_rate                 numeric(18,3),
        unit_price               numeric(18,2),
        recommended_retail_price numeric(18,2),
        typical_weight_per_unit  numeric(18,3),
        marketing_comments       text,
        internal_comments        text,
        photo                    bytea,
        custom_fields            jsonb
    )
    WHERE warehouse.stockitems."StockItemID" = p_stock_item_id;
END;
$$ LANGUAGE plpgsql;
