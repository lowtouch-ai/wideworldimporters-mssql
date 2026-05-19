CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.sales_order_lines AS
SELECT
    ol.OrderLineID,
    ol.OrderID,
    ol.Description,
    ol.Quantity,
    ol.UnitPrice,
    ol.TaxRate,
    ol.PickingCompletedWhen,
    si.StockItemName AS ProductName,
    si.Brand,
    si.Size,
    c.ColorName,
    pt.PackageTypeName
FROM sales.orderlines ol
JOIN warehouse.stockitems si ON ol.StockItemID = si.StockItemID
JOIN warehouse.colors c ON c.ColorID = si.ColorID
JOIN warehouse.package_types pt ON ol.PackageTypeID = pt.PackageTypeID;
