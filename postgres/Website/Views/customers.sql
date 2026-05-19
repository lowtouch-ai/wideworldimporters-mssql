CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE VIEW website.customers AS
SELECT
    s.CustomerID,
    s.CustomerName,
    sc.CustomerCategoryName,
    pp.FullName AS PrimaryContact,
    ap.FullName AS AlternateContact,
    s.PhoneNumber,
    s.FaxNumber,
    bg.BuyingGroupName,
    s.WebsiteURL,
    dm.DeliveryMethodName AS DeliveryMethod,
    c.CityName AS CityName,
    s.DeliveryLocation AS DeliveryLocation,
    s.DeliveryRun,
    s.RunPosition
FROM sales.customers AS s
LEFT JOIN sales.customer_categories AS sc
    ON s.CustomerCategoryID = sc.CustomerCategoryID
LEFT JOIN application.people AS pp
    ON s.PrimaryContactPersonID = pp.PersonID
LEFT JOIN application.people AS ap
    ON s.AlternateContactPersonID = ap.PersonID
LEFT JOIN sales.buying_groups AS bg
    ON s.BuyingGroupID = bg.BuyingGroupID
LEFT JOIN application.delivery_methods AS dm
    ON s.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN application.cities AS c
    ON s.DeliveryCityID = c.CityID;
