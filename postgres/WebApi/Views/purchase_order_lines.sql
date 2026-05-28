CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.purchase_order_lines AS
SELECT
    ol.PurchaseOrderLineID,
    ol.PurchaseOrderID,
    ol.Description,
    ol.IsOrderLineFinalized,
    si.StockItemName AS ProductName,
    si.Brand,
    si.Size,
    c.ColorName,
    pt.PackageTypeName,
    ol.ReceivedOuters,
    ol.OrderedOuters,
    ol.ExpectedUnitPricePerOuter
FROM purchasing.purchaseorderlines ol
JOIN warehouse.stockitems si ON ol.StockItemID = si.StockItemID
JOIN warehouse.colors c ON c.ColorID = si.ColorID
JOIN warehouse.package_types pt ON ol.PackageTypeID = pt.PackageTypeID;
