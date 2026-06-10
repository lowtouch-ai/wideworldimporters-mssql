-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForCustomers.sql
CREATE SCHEMA IF NOT EXISTS website;

-- TODO: FOR JSON AUTO, ROOT('Customers') has no direct PostgreSQL equivalent.
-- This function returns a result set instead. Callers should use json_agg(row_to_json(t))
-- or the application layer should serialize to JSON.

CREATE OR REPLACE FUNCTION website.search_for_customers(
    p_SearchText varchar(1000),
    p_MaximumRowsToReturn integer
) RETURNS TABLE (
    CustomerID integer,
    CustomerName varchar(100),
    CityName varchar(50),
    PhoneNumber varchar(20),
    FaxNumber varchar(20),
    PrimaryContactFullName varchar(50),
    PrimaryContactPreferredName varchar(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.CustomerID,
        c.CustomerName,
        ct.CityName,
        c.PhoneNumber,
        c.FaxNumber,
        p.FullName AS PrimaryContactFullName,
        p.PreferredName AS PrimaryContactPreferredName
    FROM sales.customers AS c
    JOIN application.cities AS ct ON c.DeliveryCityID = ct.CityID
    LEFT JOIN application.people AS p ON c.PrimaryContactPersonID = p.PersonID
    WHERE CONCAT(c.CustomerName, ' ', p.FullName, ' ', p.PreferredName) ILIKE '%' || p_SearchText || '%'
    ORDER BY c.CustomerName
    LIMIT p_MaximumRowsToReturn;
END;
$$ LANGUAGE plpgsql;
