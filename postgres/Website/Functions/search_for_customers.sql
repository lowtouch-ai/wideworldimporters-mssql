-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForCustomers.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.search_for_customers(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb AS $$
BEGIN
    -- TODO: verify JSON shape matches original FOR JSON AUTO, ROOT(N'Customers')
    RETURN (
        SELECT json_build_object('Customers', COALESCE(json_agg(row_to_json(t)), '[]'::json))
        FROM (
            SELECT c.customerid            AS "CustomerID",
                   c.customername          AS "CustomerName",
                   ct.cityname             AS "CityName",
                   c.phonenumber           AS "PhoneNumber",
                   c.faxnumber             AS "FaxNumber",
                   p.fullname              AS "PrimaryContactFullName",
                   p.preferredname         AS "PrimaryContactPreferredName"
            FROM sales.customers AS c
            INNER JOIN application.cities AS ct
                ON c.deliverycityid = ct.cityid
            LEFT OUTER JOIN application.people AS p
                ON c.primarycontactpersonid = p.personid
            WHERE CONCAT(c.customername, ' ', p.fullname, ' ', p.preferredname)
                  LIKE '%' || p_search_text || '%'
            ORDER BY c.customername
            LIMIT p_maximum_rows_to_return
        ) t
    );
END;
$$ LANGUAGE plpgsql;
