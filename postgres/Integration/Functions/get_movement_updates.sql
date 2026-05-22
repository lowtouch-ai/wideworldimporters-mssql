-- Converted from: wwi-ssdt/wwi-ssdt/Integration/Stored Procedures/GetMovementUpdates.sql
CREATE SCHEMA IF NOT EXISTS integration;

CREATE OR REPLACE FUNCTION integration.get_movement_updates(
    p_last_cutoff timestamp,
    p_new_cutoff  timestamp
) RETURNS TABLE(
    "Date Key"                        date,
    "WWI Stock Item Transaction ID"   integer,
    "WWI Invoice ID"                  integer,
    "WWI Purchase Order ID"           integer,
    "Quantity"                        integer,
    "WWI Stock Item ID"               integer,
    "WWI Customer ID"                 integer,
    "WWI Supplier ID"                 integer,
    "WWI Transaction Type ID"         integer,
    "Transaction Occurred When"       timestamp
) AS $$
BEGIN
    RETURN QUERY
    SELECT CAST(sit.TransactionOccurredWhen AS date),
           sit.StockItemTransactionID,
           sit.InvoiceID,
           sit.PurchaseOrderID,
           CAST(sit.Quantity AS integer),
           sit.StockItemID,
           sit.CustomerID,
           sit.SupplierID,
           sit.TransactionTypeID,
           sit.TransactionOccurredWhen
    FROM warehouse.stockitemtransactions AS sit
    WHERE sit.LastEditedWhen > p_last_cutoff
      AND sit.LastEditedWhen <= p_new_cutoff
    ORDER BY sit.StockItemTransactionID;
END;
$$ LANGUAGE plpgsql;
