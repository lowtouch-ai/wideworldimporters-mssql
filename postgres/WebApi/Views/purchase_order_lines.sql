CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.purchase_order_lines AS
SELECT
    ol.PurchaseOrderLineID,
    ol.PurchaseOrderID,
    ol.Description,
    ol.IsOrderLineFinalized,
    si.StockItemName AS "ProductName",
    si.Brand,
    si.Size,
    c.ColorName,
    pt.PackageTypeName,
    ol.ReceivedOuters,
    ol.OrderedOuters,
    ol.ExpectedUnitPricePerOuter
FROM purchasing.purchaseorderlines ol
    INNER JOIN warehouse.stockitems si
        ON ol.StockItemID = si.StockItemID
        INNER JOIN warehouse.colors c
            ON c.ColorID = si.ColorID
    INNER JOIN warehouse.packagetypes pt
        ON ol.PackageTypeID = pt.PackageTypeID;
