-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetPurchaseUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_purchase_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "Date Key" date,
    "WWI Purchase Order ID" integer,
    "Ordered Outers" integer,
    "Ordered Quantity" integer,
    "Received Outers" integer,
    "Package" varchar(50),
    "Is Order Finalized" boolean,
    "WWI Supplier ID" integer,
    "WWI Stock Item ID" integer,
    "Last Modified When" timestamp(6)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(po.OrderDate AS date),
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
    JOIN purchasing.purchaseorderlines AS pol ON po.PurchaseOrderID = pol.PurchaseOrderID
    JOIN warehouse.stockitems AS si ON pol.StockItemID = si.StockItemID
    JOIN warehouse.packagetypes AS pt ON pol.PackageTypeID = pt.PackageTypeID
    WHERE CASE WHEN pol.LastEditedWhen > po.LastEditedWhen THEN pol.LastEditedWhen ELSE po.LastEditedWhen END > p_LastCutoff
      AND CASE WHEN pol.LastEditedWhen > po.LastEditedWhen THEN pol.LastEditedWhen ELSE po.LastEditedWhen END <= p_NewCutoff
    ORDER BY po.PurchaseOrderID;
END;
$$ LANGUAGE plpgsql;
