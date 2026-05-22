-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetOrderUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_order_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "Order Date Key"        date,
    "Picked Date Key"       date,
    "WWI Order ID"          integer,
    "WWI Backorder ID"      integer,
    "Description"           varchar(100),
    "Package"               varchar(50),
    "Quantity"              integer,
    "Unit Price"            numeric(18,2),
    "Tax Rate"              numeric(18,3),
    "Total Excluding Tax"   numeric,
    "Tax Amount"            numeric,
    "Total Including Tax"   numeric,
    "WWI City ID"           integer,
    "WWI Customer ID"       integer,
    "WWI Stock Item ID"     integer,
    "WWI Salesperson ID"    integer,
    "WWI Picker ID"         integer,
    "Last Modified When"    timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT CAST(o.OrderDate AS date),
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
    INNER JOIN sales.orderlines AS ol ON o.OrderID = ol.OrderID
    INNER JOIN warehouse.package_types AS pt ON ol.PackageTypeID = pt.PackageTypeID
    INNER JOIN sales.customers AS c ON c.CustomerID = o.CustomerID
    WHERE CASE WHEN ol.LastEditedWhen > o.LastEditedWhen THEN ol.LastEditedWhen ELSE o.LastEditedWhen END > p_last_cutoff
      AND CASE WHEN ol.LastEditedWhen > o.LastEditedWhen THEN ol.LastEditedWhen ELSE o.LastEditedWhen END <= p_new_cutoff
    ORDER BY o.OrderID;
END;
$$ LANGUAGE plpgsql;
