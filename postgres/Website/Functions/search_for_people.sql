-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForPeople.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.search_for_people(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb AS $$
BEGIN
    -- TODO: verify JSON shape matches original FOR JSON AUTO, ROOT(N'People')
    RETURN (
        SELECT json_build_object('People', COALESCE(json_agg(row_to_json(t)), '[]'::json))
        FROM (
            SELECT p.personid      AS "PersonID",
                   p.fullname      AS "FullName",
                   p.preferredname AS "PreferredName",
                   CASE WHEN p.issalesperson                THEN 'Salesperson'
                        WHEN p.isemployee                   THEN 'Employee'
                        WHEN c.customerid   IS NOT NULL     THEN 'Customer'
                        WHEN sp.supplierid  IS NOT NULL     THEN 'Supplier'
                        WHEN sa.supplierid  IS NOT NULL     THEN 'Supplier'
                   END AS "Relationship",
                   COALESCE(c.customername, sp.suppliername, sa.suppliername, 'WWI') AS "Company"
            FROM application.people AS p
            LEFT OUTER JOIN sales.customers AS c
                ON c.primarycontactpersonid = p.personid
            LEFT OUTER JOIN purchasing.suppliers AS sp
                ON sp.primarycontactpersonid = p.personid
            LEFT OUTER JOIN purchasing.suppliers AS sa
                ON sa.alternatecontactpersonid = p.personid
            WHERE p.searchname LIKE '%' || p_search_text || '%'
            ORDER BY p.fullname
            LIMIT p_maximum_rows_to_return
        ) t
    );
END;
$$ LANGUAGE plpgsql;
