CREATE SCHEMA IF NOT EXISTS webapi;

-- TODO: FOR JSON PATH not supported in PostgreSQL.
-- The DeliveryLocation column uses json_build_object as an approximation.
-- geography .Long/.Lat → ST_X()/ST_Y() (PostGIS required).
-- Original MSSQL used: FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
CREATE OR REPLACE VIEW webapi.customers AS
SELECT
    c.CustomerID,
    c.CustomerName,
    sc.CustomerCategoryName,
    pp.FullName AS "PrimaryContact",
    ap.FullName AS "AlternateContact",
    c.PhoneNumber,
    c.FaxNumber,
    c.WebsiteURL,
    c.PostalAddressLine1,
    c.PostalAddressLine2,
    c.PostalPostalCode,
    c.PostalCityID,
    pc.CityName AS "PostalCity",
    c.AccountOpenedDate,
    c.CreditLimit,
    c.IsOnCreditHold,
    c.IsStatementSent,
    c.PaymentDays,
    c.RunPosition,
    c.StandardDiscountPercentage,
    bg.BuyingGroupName,
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(c.DeliveryLocation), ST_Y(c.DeliveryLocation))
        ),
        'properties', json_build_object(
            'DeliveryMethod', dm.DeliveryMethodName,
            'CityName', pc.CityName,
            'Province', sp.StateProvinceName,
            'Territory', sp.SalesTerritory
        )
    ) AS "DeliveryLocation",
    c.PrimaryContactPersonID,
    c.AlternateContactPersonID,
    c.BillToCustomerID,
    c.BuyingGroupID,
    c.CustomerCategoryID
FROM sales.customers AS c
LEFT JOIN sales.customercategories AS sc
    ON c.CustomerCategoryID = sc.CustomerCategoryID
LEFT JOIN application.people AS pp
    ON c.PrimaryContactPersonID = pp.PersonID
LEFT JOIN application.people AS ap
    ON c.AlternateContactPersonID = ap.PersonID
LEFT JOIN sales.buyinggroups AS bg
    ON c.BuyingGroupID = bg.BuyingGroupID
LEFT JOIN application.deliverymethods AS dm
    ON c.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN application.cities AS pc
    ON c.PostalCityID = pc.CityID
LEFT JOIN application.stateprovinces AS sp
    ON sp.StateProvinceID = pc.StateProvinceID;
