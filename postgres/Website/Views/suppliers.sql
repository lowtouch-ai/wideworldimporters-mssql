-- Converted from: wwi-ssdt/wwi-ssdt/Website/Views/Suppliers.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE VIEW website.suppliers AS
SELECT s.SupplierID,
       s.SupplierName,
       sc.SupplierCategoryName,
       pp.FullName AS PrimaryContact,
       ap.FullName AS AlternateContact,
       s.PhoneNumber,
       s.FaxNumber,
       s.WebsiteURL,
       dm.DeliveryMethodName AS DeliveryMethod,
       c.CityName AS CityName,
       s.DeliveryLocation AS DeliveryLocation,
       s.SupplierReference
FROM purchasing.suppliers AS s
LEFT JOIN purchasing.suppliercategories AS sc
    ON s.SupplierCategoryID = sc.SupplierCategoryID
LEFT JOIN application.people AS pp
    ON s.PrimaryContactPersonID = pp.PersonID
LEFT JOIN application.people AS ap
    ON s.AlternateContactPersonID = ap.PersonID
LEFT JOIN application.deliverymethods AS dm
    ON s.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN application.cities AS c
    ON s.DeliveryCityID = c.CityID;
