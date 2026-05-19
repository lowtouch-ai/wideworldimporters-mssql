-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetOrderUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_order_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "Order Date Key" date,
    "Picked Date Key" date,
    "WWI Order ID" integer,
    "WWI Backorder ID" integer,
    "Description" varchar(100),
    "Package" varchar(50),
    "Quantity" integer,
    "Unit Price" numeric(18,2),
    "Tax Rate" numeric(18,3),
    "Total Excluding Tax" numeric(18,2),
    "Tax Amount" numeric(18,2),
    "Total Including Tax" numeric(18,2),
    "WWI City ID" integer,
    "WWI Customer ID" integer,
    "WWI Stock Item ID" integer,
    "WWI Salesperson ID" integer,
    "WWI Picker ID" integer,
    "Last Modified When" timestamp(6)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(o.OrderDate AS date),
        CAST(ol.PickingCompletedWhen AS date),
        o.OrderID,
        o.BackorderOrderID,
        ol.Description,
        pt.PackageTypeName,
        ol.Quantity,
        ol.UnitPrice,
        ol.TaxRate,
        ROUND(ol.Quantity * ol.UnitPrice, 2),
        ROUND(ol.Quantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
        ROUND(ol.Quantity * ol.UnitPrice, 2) + ROUND(ol.Quantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
        c.DeliveryCityID,
        c.CustomerID,
        ol.StockItemID,
        o.SalespersonPersonID,
        o.PickedByPersonID,
        CASE WHEN ol.LastEditedWhen > o.LastEditedWhen THEN ol.LastEditedWhen ELSE o.LastEditedWhen END
    FROM sales.orders AS o
    JOIN sales.orderlines AS ol ON o.OrderID = ol.OrderID
    JOIN warehouse.packagetypes AS pt ON ol.PackageTypeID = pt.PackageTypeID
    JOIN sales.customers AS c ON c.CustomerID = o.CustomerID
    WHERE CASE WHEN ol.LastEditedWhen > o.LastEditedWhen THEN ol.LastEditedWhen ELSE o.LastEditedWhen END > p_LastCutoff
      AND CASE WHEN ol.LastEditedWhen > o.LastEditedWhen THEN ol.LastEditedWhen ELSE o.LastEditedWhen END <= p_NewCutoff
    ORDER BY o.OrderID;
END;
$$ LANGUAGE plpgsql;
