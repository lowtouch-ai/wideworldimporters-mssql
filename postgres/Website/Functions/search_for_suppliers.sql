-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForSuppliers.sql
CREATE SCHEMA IF NOT EXISTS website;

-- TODO: FOR JSON AUTO, ROOT('Suppliers') has no direct PostgreSQL equivalent.
-- This function returns a result set. Callers can wrap with json_agg(row_to_json(t)).

CREATE OR REPLACE FUNCTION website.search_for_suppliers(
    p_SearchText varchar(1000),
    p_MaximumRowsToReturn integer
) RETURNS TABLE (
    SupplierID integer,
    SupplierName varchar(100),
    CityName varchar(50),
    PhoneNumber varchar(20),
    FaxNumber varchar(20),
    PrimaryContactFullName varchar(50),
    PrimaryContactPreferredName varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.SupplierID,
        s.SupplierName,
        c.CityName,
        s.PhoneNumber,
        s.FaxNumber,
        p.FullName AS PrimaryContactFullName,
        p.PreferredName AS PrimaryContactPreferredName
    FROM purchasing.suppliers AS s
    JOIN application.cities AS c ON s.DeliveryCityID = c.CityID
    LEFT JOIN application.people AS p ON s.PrimaryContactPersonID = p.PersonID
    WHERE CONCAT(s.SupplierName, ' ', p.FullName, ' ', p.PreferredName) ILIKE '%' || p_SearchText || '%'
    ORDER BY s.SupplierName
    LIMIT p_MaximumRowsToReturn;
END;
$$ LANGUAGE plpgsql;
