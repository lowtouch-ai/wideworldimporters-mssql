CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.suppliers AS
SELECT
    s.SupplierID,
    s.SupplierName,
    sc.SupplierCategoryName,
    pp.FullName AS PrimaryContact,
    ap.FullName AS AlternateContact,
    s.PhoneNumber,
    s.FaxNumber,
    s.WebsiteURL,
    s.SupplierReference,
    s.BankAccountName,
    s.BankAccountBranch,
    s.BankAccountCode,
    s.BankAccountNumber,
    s.BankInternationalCode,
    s.PostalAddressLine1,
    s.PostalAddressLine2,
    s.PostalPostalCode,
    s.PaymentDays,
    s.SupplierCategoryID,
    -- TODO: verify JSON shape matches original FOR JSON PATH output
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(s.DeliveryLocation::geometry), ST_Y(s.DeliveryLocation::geometry))
        ),
        'properties', json_build_object(
            'DeliveryMethod', dm.DeliveryMethodName,
            'DeliveryMethodID', s.DeliveryMethodID,
            'City', c.CityName,
            'Province', sp.StateProvinceName,
            'Territory', sp.SalesTerritory
        )
    ) AS DeliveryLocation
FROM purchasing.suppliers AS s
LEFT JOIN purchasing.supplier_categories AS sc ON s.SupplierCategoryID = sc.SupplierCategoryID
LEFT JOIN application.people AS pp ON s.PrimaryContactPersonID = pp.PersonID
LEFT JOIN application.people AS ap ON s.AlternateContactPersonID = ap.PersonID
LEFT JOIN application.delivery_methods AS dm ON s.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN application.cities AS c ON s.DeliveryCityID = c.CityID
LEFT JOIN application.state_provinces AS sp ON sp.StateProvinceID = c.StateProvinceID;
