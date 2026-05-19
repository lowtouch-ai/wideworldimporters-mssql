CREATE SCHEMA IF NOT EXISTS webapi;

-- TODO: FOR JSON PATH not supported in PostgreSQL.
-- The DeliveryLocation column uses json_build_object as an approximation.
-- geography .Long/.Lat → ST_X()/ST_Y() (PostGIS required).
-- Original MSSQL used: FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
CREATE OR REPLACE VIEW webapi.suppliers AS
SELECT
    s.SupplierID,
    s.SupplierName,
    sc.SupplierCategoryName,
    pp.FullName AS "PrimaryContact",
    ap.FullName AS "AlternateContact",
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
    json_build_object(
        'type', 'Feature',
        'geometry', json_build_object(
            'type', 'Point',
            'coordinates', json_build_array(ST_X(s.DeliveryLocation), ST_Y(s.DeliveryLocation))
        ),
        'properties', json_build_object(
            'DeliveryMethod', dm.DeliveryMethodName,
            'DeliveryMethodID', s.DeliveryMethodID,
            'City', c.CityName,
            'Province', sp.StateProvinceName,
            'Territory', sp.SalesTerritory
        )
    ) AS "DeliveryLocation"
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
        ON s.DeliveryCityID = c.CityID
        LEFT JOIN application.stateprovinces AS sp
            ON sp.StateProvinceID = c.StateProvinceID;
