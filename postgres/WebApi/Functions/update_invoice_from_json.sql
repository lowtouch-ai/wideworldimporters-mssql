-- Converted from: wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateInvoiceFromJson.sql
CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE FUNCTION webapi.update_invoice_from_json(
    p_invoice text,
    p_invoice_id integer,
    p_user_id integer
) RETURNS void AS $$
BEGIN
    UPDATE sales.invoices SET
        CustomerID = COALESCE(json.CustomerID, sales.invoices.CustomerID),
        BillToCustomerID = COALESCE(json.BillToCustomerID, sales.invoices.BillToCustomerID),
        DeliveryMethodID = COALESCE(json.DeliveryMethodID, sales.invoices.DeliveryMethodID),
        ContactPersonID = COALESCE(json.ContactPersonID, sales.invoices.ContactPersonID),
        AccountsPersonID = COALESCE(json.AccountsPersonID, sales.invoices.AccountsPersonID),
        SalespersonPersonID = COALESCE(json.SalespersonPersonID, sales.invoices.SalespersonPersonID),
        PackedByPersonID = COALESCE(json.PackedByPersonID, sales.invoices.PackedByPersonID),
        InvoiceDate = COALESCE(json.InvoiceDate, sales.invoices.InvoiceDate),
        CustomerPurchaseOrderNumber = json.CustomerPurchaseOrderNumber,
        IsCreditNote = COALESCE(json.IsCreditNote, sales.invoices.IsCreditNote),
        TotalDryItems = COALESCE(json.TotalDryItems, sales.invoices.TotalDryItems),
        TotalChillerItems = COALESCE(json.TotalChillerItems, sales.invoices.TotalChillerItems),
        DeliveryRun = json.DeliveryRun,
        RunPosition = json.RunPosition,
        LastEditedBy = p_user_id
    FROM jsonb_to_record(p_invoice::jsonb) AS json(
        CustomerID integer,
        BillToCustomerID integer,
        OrderID integer,
        DeliveryMethodID integer,
        ContactPersonID integer,
        AccountsPersonID integer,
        SalespersonPersonID integer,
        PackedByPersonID integer,
        InvoiceDate date,
        CustomerPurchaseOrderNumber varchar(20),
        IsCreditNote boolean,
        TotalDryItems integer,
        TotalChillerItems integer,
        DeliveryRun varchar(5),
        RunPosition varchar(5)
    )
    WHERE InvoiceID = p_invoice_id;
END;
$$ LANGUAGE plpgsql;
