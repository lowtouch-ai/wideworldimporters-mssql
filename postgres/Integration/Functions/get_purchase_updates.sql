-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPurchaseUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_purchase_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "Date Key"                date,
    "WWI Purchase Order ID"   integer,
    "Ordered Outers"          integer,
    "Ordered Quantity"        integer,
    "Received Outers"         integer,
    "Package"                 varchar(50),
    "Is Order Finalized"      boolean,
    "WWI Supplier ID"         integer,
    "WWI Stock Item ID"       integer,
    "Last Modified When"      timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT CAST(po.OrderDate AS date),
           po.PurchaseOrderID,
           pol.OrderedOuters,
           pol.OrderedOuters * si.QuantityPerOuter,
           pol.ReceivedOuters,
           pt.PackageTypeName,
           pol.IsOrderLineFinalized,
           po.SupplierID,
           pol.StockItemID,
           CASE WHEN pol.LastEditedWhen > po.LastEditedWhen THEN pol.LastEditedWhen ELSE po.LastEditedWhen END
    FROM purchasing.purchaseorders AS po
    INNER JOIN purchasing.purchaseorderlines AS pol ON po.PurchaseOrderID = pol.PurchaseOrderID
    INNER JOIN warehouse.stockitems AS si ON pol.StockItemID = si.StockItemID
    INNER JOIN warehouse.package_types AS pt ON pol.PackageTypeID = pt.PackageTypeID
    WHERE CASE WHEN pol.LastEditedWhen > po.LastEditedWhen THEN pol.LastEditedWhen ELSE po.LastEditedWhen END > p_last_cutoff
      AND CASE WHEN pol.LastEditedWhen > po.LastEditedWhen THEN pol.LastEditedWhen ELSE po.LastEditedWhen END <= p_new_cutoff
    ORDER BY po.PurchaseOrderID;
END;
$$ LANGUAGE plpgsql;
