-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForPeople.sql
CREATE SCHEMA IF NOT EXISTS website;

-- TODO: FOR JSON AUTO, ROOT('People') has no direct PostgreSQL equivalent.
-- This function returns a result set instead. Callers can wrap with json_agg(row_to_json(t)).

CREATE OR REPLACE FUNCTION website.search_for_people(
    p_SearchText varchar(1000),
    p_MaximumRowsToReturn integer
) RETURNS TABLE (
    PersonID integer,
    FullName varchar(50),
    PreferredName varchar(50),
    Relationship varchar(20),
    Company varchar(100)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.PersonID,
        p.FullName,
        p.PreferredName,
        CASE
            WHEN p.IsSalesperson THEN 'Salesperson'
            WHEN p.IsEmployee THEN 'Employee'
            WHEN c.CustomerID IS NOT NULL THEN 'Customer'
            WHEN sp.SupplierID IS NOT NULL THEN 'Supplier'
            WHEN sa.SupplierID IS NOT NULL THEN 'Supplier'
        END::varchar(20) AS Relationship,
        COALESCE(c.CustomerName, sp.SupplierName, sa.SupplierName, 'WWI')::varchar(100) AS Company
    FROM application.people AS p
    LEFT JOIN sales.customers AS c ON c.PrimaryContactPersonID = p.PersonID
    LEFT JOIN purchasing.suppliers AS sp ON sp.PrimaryContactPersonID = p.PersonID
    LEFT JOIN purchasing.suppliers AS sa ON sa.AlternateContactPersonID = p.PersonID
    WHERE p.SearchName ILIKE '%' || p_SearchText || '%'
    ORDER BY p.FullName
    LIMIT p_MaximumRowsToReturn;
END;
$$ LANGUAGE plpgsql;
