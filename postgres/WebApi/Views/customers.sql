CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.customers AS
SELECT
    c.CustomerID,
    c.CustomerName,
    sc.CustomerCategoryName,
    pp.FullName AS PrimaryContact,
    ap.FullName AS AlternateContact,
    c.PhoneNumber,
    c.FaxNumber,
    c.WebsiteURL,
    c.PostalAddressLine1,
    c.PostalAddressLine2,
    c.PostalPostalCode,
    c.PostalCityID,
    pc.CityName AS PostalCity,
    c.AccountOpenedDate,
    c.CreditLimit,
    c.IsOnCreditHold,
    c.IsStatementSent,
    c.PaymentDays,
    c.RunPosition,
    c.StandardDiscountPercentage,
    bg.BuyingGroupName,
    -- TODO: verify JSON shape matches original FOR JSON PATH output
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(c.DeliveryLocation::geometry), ST_Y(c.DeliveryLocation::geometry))
        ),
        'properties', json_build_object(
            'DeliveryMethod', dm.DeliveryMethodName,
            'CityName', pc.CityName,
            'Province', sp.StateProvinceName,
            'Territory', sp.SalesTerritory
        )
    ) AS DeliveryLocation,
    c.PrimaryContactPersonID,
    c.AlternateContactPersonID,
    c.BillToCustomerID,
    c.BuyingGroupID,
    c.CustomerCategoryID
FROM sales.customers AS c
LEFT JOIN sales.customer_categories AS sc
    ON c.CustomerCategoryID = sc.CustomerCategoryID
LEFT JOIN application.people AS pp
    ON c.PrimaryContactPersonID = pp.PersonID
LEFT JOIN application.people AS ap
    ON c.AlternateContactPersonID = ap.PersonID
LEFT JOIN sales.buying_groups AS bg
    ON c.BuyingGroupID = bg.BuyingGroupID
LEFT JOIN application.delivery_methods AS dm
    ON c.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN application.cities AS pc
    ON c.PostalCityID = pc.CityID
LEFT JOIN application.state_provinces AS sp
    ON sp.StateProvinceID = pc.StateProvinceID;
