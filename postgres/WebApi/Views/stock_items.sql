CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.stock_items AS
SELECT
    si.StockItemID,
    si.StockItemName,
    s.SupplierName,
    s.SupplierReference,
    c.ColorName,
    opt.PackageTypeName AS OuterPackage,
    upt.PackageTypeName AS UnitPackage,
    si.Brand,
    si.Size,
    si.LeadTimeDays,
    si.QuantityPerOuter,
    si.IsChillerStock,
    si.Barcode,
    si.TaxRate,
    si.UnitPrice,
    si.RecommendedRetailPrice,
    si.TypicalWeightPerUnit,
    si.MarketingComments,
    si.InternalComments,
    si.CustomFields,
    sih.QuantityOnHand,
    sih.BinLocation,
    sih.LastStocktakeQuantity,
    sih.LastCostPrice,
    sih.ReorderLevel,
    sih.TargetStockLevel,
    si.SupplierID,
    si.ColorID,
    si.UnitPackageID,
    si.OuterPackageID
FROM warehouse.stockitems AS si
    INNER JOIN warehouse.stockitemholdings AS sih ON si.StockItemID = sih.StockItemID
    INNER JOIN purchasing.suppliers AS s ON si.SupplierID = s.SupplierID
    INNER JOIN warehouse.colors AS c ON si.ColorID = c.ColorID
    INNER JOIN warehouse.packagetypes AS opt ON si.OuterPackageID = opt.PackageTypeID
    INNER JOIN warehouse.packagetypes AS upt ON si.UnitPackageID = upt.PackageTypeID;
