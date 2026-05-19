CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.invoices AS
SELECT
    inv.InvoiceID,
    inv.InvoiceDate,
    inv.CustomerPurchaseOrderNumber,
    inv.IsCreditNote,
    inv.TotalDryItems,
    inv.TotalChillerItems,
    inv.DeliveryRun,
    inv.RunPosition,
    inv.ReturnedDeliveryData,
    inv.ConfirmedDeliveryTime,
    inv.ConfirmedReceivedBy,
    c.CustomerName,
    sp.FullName AS SalesPersonName,
    contact.FullName AS ContactName,
    contact.PhoneNumber AS ContactPhone,
    contact.EmailAddress AS ContactEmail,
    sp.EmailAddress AS SalesPersonEmail,
    dm.DeliveryMethodName,
    inv.CustomerID,
    inv.OrderID,
    inv.DeliveryMethodID,
    inv.ContactPersonID,
    inv.AccountsPersonID,
    inv.SalespersonPersonID,
    inv.PackedByPersonID
FROM sales.invoices AS inv
JOIN sales.customers AS c ON inv.CustomerID = c.CustomerID
JOIN application.delivery_methods AS dm ON inv.DeliveryMethodID = dm.DeliveryMethodID
JOIN application.people AS contact ON inv.ContactPersonID = contact.PersonID
JOIN application.people AS sp ON inv.SalespersonPersonID = sp.PersonID;
