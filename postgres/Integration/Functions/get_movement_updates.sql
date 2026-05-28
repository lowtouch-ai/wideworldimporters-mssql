-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetMovementUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_movement_updates(
    p_LastCutoff timestamp(6),
    p_NewCutoff timestamp(6)
) RETURNS TABLE (
    "Date Key" date,
    "WWI Stock Item Transaction ID" integer,
    "WWI Invoice ID" integer,
    "WWI Purchase Order ID" integer,
    "Quantity" integer,
    "WWI Stock Item ID" integer,
    "WWI Customer ID" integer,
    "WWI Supplier ID" integer,
    "WWI Transaction Type ID" integer,
    "Transaction Occurred When" timestamp(6)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        CAST(sit.TransactionOccurredWhen AS date) AS "Date Key",
        sit.StockItemTransactionID AS "WWI Stock Item Transaction ID",
        sit.InvoiceID AS "WWI Invoice ID",
        sit.PurchaseOrderID AS "WWI Purchase Order ID",
        CAST(sit.Quantity AS integer) AS "Quantity",
        sit.StockItemID AS "WWI Stock Item ID",
        sit.CustomerID AS "WWI Customer ID",
        sit.SupplierID AS "WWI Supplier ID",
        sit.TransactionTypeID AS "WWI Transaction Type ID",
        sit.TransactionOccurredWhen AS "Transaction Occurred When"
    FROM warehouse.stockitemtransactions AS sit
    WHERE sit.LastEditedWhen > p_LastCutoff
      AND sit.LastEditedWhen <= p_NewCutoff
    ORDER BY sit.StockItemTransactionID;
END;
$$ LANGUAGE plpgsql;
