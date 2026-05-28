-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/InvoiceCustomerOrders.sql
CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: MSSQL TVP parameter @OrdersToInvoice (Website.OrderIDList) replaced with jsonb.
-- Callers must pass a JSON array of objects with an "OrderID" field.
-- TODO: Consider using composite type from postgres/Website/Types/order_id_list.sql

CREATE OR REPLACE FUNCTION website.invoice_customer_orders(
    p_OrdersToInvoice jsonb,
    p_PackedByPersonID integer,
    p_InvoicedByPersonID integer
) RETURNS void AS $$
DECLARE
    _rowcount integer;
BEGIN
    CREATE TEMP TABLE _invoices_to_generate (
        OrderID integer PRIMARY KEY,
        InvoiceID integer NOT NULL,
        TotalDryItems integer NOT NULL,
        TotalChillerItems integer NOT NULL
    ) ON COMMIT DROP;

    -- Check that all orders exist, have been fully picked, and not already invoiced.
    -- Allocate new invoice IDs.
    INSERT INTO _invoices_to_generate (OrderID, InvoiceID, TotalDryItems, TotalChillerItems)
    SELECT oti_val::integer AS OrderID,
           nextval('sequences.invoice_id_seq'),
           COALESCE((SELECT SUM(CASE WHEN si.IsChillerStock <> true THEN 0 ELSE 0 END
                              + CASE WHEN si.IsChillerStock = false THEN 1 ELSE 0 END)
                     FROM sales.orderlines AS ol
                     JOIN warehouse.stockitems AS si ON ol.StockItemID = si.StockItemID
                     WHERE ol.OrderID = oti_val::integer), 0),
           COALESCE((SELECT SUM(CASE WHEN si.IsChillerStock = true THEN 1 ELSE 0 END)
                     FROM sales.orderlines AS ol
                     JOIN warehouse.stockitems AS si ON ol.StockItemID = si.StockItemID
                     WHERE ol.OrderID = oti_val::integer), 0)
    FROM jsonb_array_elements_text(p_OrdersToInvoice) AS oti_val
    JOIN sales.orders AS o ON o.OrderID = oti_val::integer
    WHERE NOT EXISTS (SELECT 1 FROM sales.invoices AS i WHERE i.OrderID = oti_val::integer)
    AND o.PickingCompletedWhen IS NOT NULL;

    -- Verify all requested orders were processed
    IF EXISTS (
        SELECT 1 FROM jsonb_array_elements_text(p_OrdersToInvoice) AS oti_val
        WHERE NOT EXISTS (SELECT 1 FROM _invoices_to_generate AS itg WHERE itg.OrderID = oti_val::integer)
    ) THEN
        RAISE NOTICE 'At least one order ID either does not exist, is not picked, or is already invoiced';
        RAISE EXCEPTION 'At least one orderID either does not exist, is not picked, or is already invoiced'
            USING ERRCODE = 'P0001';
    END IF;

    INSERT INTO sales.invoices
        (InvoiceID, CustomerID, BillToCustomerID, OrderID, DeliveryMethodID, ContactPersonID,
         AccountsPersonID, SalespersonPersonID, PackedByPersonID, InvoiceDate,
         CustomerPurchaseOrderNumber, IsCreditNote, CreditNoteReason, Comments,
         DeliveryInstructions, InternalComments, TotalDryItems, TotalChillerItems,
         DeliveryRun, RunPosition, ReturnedDeliveryData, LastEditedBy, LastEditedWhen)
    SELECT itg.InvoiceID, c.CustomerID, c.BillToCustomerID, itg.OrderID, c.DeliveryMethodID,
           o.ContactPersonID, btc.PrimaryContactPersonID,
           o.SalespersonPersonID, p_PackedByPersonID, CURRENT_TIMESTAMP,
           o.CustomerPurchaseOrderNumber,
           false, NULL, NULL,
           c.DeliveryAddressLine1 || ', ' || c.DeliveryAddressLine2,
           NULL,
           itg.TotalDryItems, itg.TotalChillerItems,
           c.DeliveryRun, c.RunPosition,
           -- TODO: JSON_MODIFY → jsonb_set / || operator
           jsonb_build_object(
               'Events', jsonb_build_array(
                   jsonb_build_object(
                       'Event', 'Ready for collection',
                       'EventTime', to_char(CURRENT_TIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS'),
                       'ConNote', 'EAN-125-' || (itg.InvoiceID + 1050)::text
                   )
               )
           )::text,
           p_InvoicedByPersonID, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    JOIN sales.orders AS o ON itg.OrderID = o.OrderID
    JOIN sales.customers AS c ON o.CustomerID = c.CustomerID
    JOIN sales.customers AS btc ON btc.CustomerID = c.BillToCustomerID;

    INSERT INTO sales.invoicelines
        (InvoiceID, StockItemID, Description, PackageTypeID, Quantity, UnitPrice,
         TaxRate, TaxAmount, LineProfit, ExtendedPrice, LastEditedBy, LastEditedWhen)
    SELECT itg.InvoiceID, ol.StockItemID, ol.Description, ol.PackageTypeID,
           ol.PickedQuantity, ol.UnitPrice, ol.TaxRate,
           ROUND(ol.PickedQuantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
           ROUND(ol.PickedQuantity * (ol.UnitPrice - sih.LastCostPrice), 2),
           ROUND(ol.PickedQuantity * ol.UnitPrice, 2)
             + ROUND(ol.PickedQuantity * ol.UnitPrice * ol.TaxRate / 100.0, 2),
           p_InvoicedByPersonID, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    JOIN sales.orderlines AS ol ON itg.OrderID = ol.OrderID
    JOIN warehouse.stockitems AS si ON ol.StockItemID = si.StockItemID
    JOIN warehouse.stockitemholdings AS sih ON si.StockItemID = sih.StockItemID
    ORDER BY ol.OrderID, ol.OrderLineID;

    INSERT INTO warehouse.stockitemtransactions
        (StockItemID, TransactionTypeID, CustomerID, InvoiceID, SupplierID, PurchaseOrderID,
         TransactionOccurredWhen, Quantity, LastEditedBy, LastEditedWhen)
    SELECT il.StockItemID,
           (SELECT TransactionTypeID FROM application.transactiontypes WHERE TransactionTypeName = 'Stock Issue'),
           i.CustomerID, i.InvoiceID, NULL, NULL,
           CURRENT_TIMESTAMP, 0 - il.Quantity, p_InvoicedByPersonID, CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    JOIN sales.invoicelines AS il ON itg.InvoiceID = il.InvoiceID
    JOIN sales.invoices AS i ON il.InvoiceID = i.InvoiceID
    ORDER BY il.InvoiceID, il.InvoiceLineID;

    -- Update stock holdings
    WITH StockItemTotals AS (
        SELECT il.StockItemID, SUM(il.Quantity) AS TotalQuantity
        FROM sales.invoicelines AS il
        WHERE il.InvoiceID IN (SELECT InvoiceID FROM _invoices_to_generate)
        GROUP BY il.StockItemID
    )
    UPDATE warehouse.stockitemholdings AS sih
    SET QuantityOnHand = sih.QuantityOnHand - sit.TotalQuantity,
        LastEditedBy = p_InvoicedByPersonID,
        LastEditedWhen = CURRENT_TIMESTAMP
    FROM StockItemTotals AS sit
    WHERE sih.StockItemID = sit.StockItemID;

    INSERT INTO sales.customertransactions
        (CustomerID, TransactionTypeID, InvoiceID, PaymentMethodID, TransactionDate,
         AmountExcludingTax, TaxAmount, TransactionAmount, OutstandingBalance,
         FinalizationDate, LastEditedBy, LastEditedWhen)
    SELECT i.BillToCustomerID,
           (SELECT TransactionTypeID FROM application.transactiontypes WHERE TransactionTypeName = 'Customer Invoice'),
           itg.InvoiceID,
           NULL,
           CURRENT_TIMESTAMP,
           (SELECT SUM(il.ExtendedPrice - il.TaxAmount) FROM sales.invoicelines AS il WHERE il.InvoiceID = itg.InvoiceID),
           (SELECT SUM(il.TaxAmount) FROM sales.invoicelines AS il WHERE il.InvoiceID = itg.InvoiceID),
           (SELECT SUM(il.ExtendedPrice) FROM sales.invoicelines AS il WHERE il.InvoiceID = itg.InvoiceID),
           (SELECT SUM(il.ExtendedPrice) FROM sales.invoicelines AS il WHERE il.InvoiceID = itg.InvoiceID),
           NULL,
           p_InvoicedByPersonID,
           CURRENT_TIMESTAMP
    FROM _invoices_to_generate AS itg
    JOIN sales.invoices AS i ON itg.InvoiceID = i.InvoiceID;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Unable to invoice these orders';
        RAISE;
END;
$$ LANGUAGE plpgsql;
