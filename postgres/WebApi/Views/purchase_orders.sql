CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.purchase_orders AS
SELECT
    o.PurchaseOrderID,
    o.OrderDate,
    o.ExpectedDeliveryDate,
    o.SupplierReference,
    o.IsOrderFinalized,
    dm.DeliveryMethodName,
    o.DeliveryMethodID,
    o.SupplierID,
    c.FullName AS ContactName,
    c.PhoneNumber AS ContactPhone,
    c.FaxNumber AS ContactFax,
    c.EmailAddress AS ContactEmail
FROM purchasing.purchaseorders o
JOIN application.people c ON o.ContactPersonID = c.PersonID
JOIN application.delivery_methods dm ON o.DeliveryMethodID = dm.DeliveryMethodID;
