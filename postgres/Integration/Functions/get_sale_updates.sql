-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetSaleUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_sale_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "Invoice Date Key" date,
    "Delivery Date Key" date,
    "WWI Invoice ID" integer,
    "Description" varchar(100),
    "Package" varchar(50),
    "Quantity" integer,
    "Unit Price" numeric(18,2),
    "Tax Rate" numeric(18,3),
    "Total Excluding Tax" numeric(18,2),
    "Tax Amount" numeric(18,2),
    "Profit" numeric(18,2),
    "Total Including Tax" numeric(18,2),
    "Total Dry Items" integer,
    "Total Chiller Items" integer,
    "WWI City ID" integer,
    "WWI Customer ID" integer,
    "WWI Bill To Customer ID" integer,
    "WWI Stock Item ID" integer,
    "WWI Saleperson ID" integer,
    "Last Modified When" timestamp(6)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(i.InvoiceDate AS date),
        CAST(i.ConfirmedDeliveryTime AS date),
        i.InvoiceID,
        il.Description,
        pt.PackageTypeName,
        il.Quantity,
        il.UnitPrice,
        il.TaxRate,
        il.ExtendedPrice - il.TaxAmount,
        il.TaxAmount,
        il.LineProfit,
        il.ExtendedPrice,
        CASE WHEN si.IsChillerStock = false THEN il.Quantity ELSE 0 END,
        CASE WHEN si.IsChillerStock THEN il.Quantity ELSE 0 END,
        c.DeliveryCityID,
        i.CustomerID,
        i.BillToCustomerID,
        il.StockItemID,
        i.SalespersonPersonID,
        CASE WHEN il.LastEditedWhen > i.LastEditedWhen THEN il.LastEditedWhen ELSE i.LastEditedWhen END
    FROM sales.invoices AS i
    JOIN sales.invoicelines AS il ON i.InvoiceID = il.InvoiceID
    JOIN warehouse.stockitems AS si ON il.StockItemID = si.StockItemID
    JOIN warehouse.packagetypes AS pt ON il.PackageTypeID = pt.PackageTypeID
    JOIN sales.customers AS c ON i.CustomerID = c.CustomerID
    JOIN sales.customers AS bt ON i.BillToCustomerID = bt.CustomerID
    WHERE CASE WHEN il.LastEditedWhen > i.LastEditedWhen THEN il.LastEditedWhen ELSE i.LastEditedWhen END > p_LastCutoff
      AND CASE WHEN il.LastEditedWhen > i.LastEditedWhen THEN il.LastEditedWhen ELSE i.LastEditedWhen END <= p_NewCutoff
    ORDER BY i.InvoiceID, il.InvoiceLineID;
END;
$$ LANGUAGE plpgsql;
