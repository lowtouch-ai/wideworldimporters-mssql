-- Converted from: wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForSuppliers.sql
CREATE SCHEMA IF NOT EXISTS website;

CREATE OR REPLACE FUNCTION website.search_for_suppliers(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb AS $$
BEGIN
    -- TODO: verify JSON shape matches original FOR JSON AUTO, ROOT(N'Suppliers')
    RETURN (
        SELECT json_build_object('Suppliers', COALESCE(json_agg(row_to_json(t)), '[]'::json))
        FROM (
            SELECT s.supplierid       AS "SupplierID",
                   s.suppliername     AS "SupplierName",
                   c.cityname         AS "CityName",
                   s.phonenumber      AS "PhoneNumber",
                   s.faxnumber        AS "FaxNumber",
                   p.fullname         AS "PrimaryContactFullName",
                   p.preferredname    AS "PrimaryContactPreferredName"
            FROM purchasing.suppliers AS s
            INNER JOIN application.cities AS c
                ON s.deliverycityid = c.cityid
            LEFT OUTER JOIN application.people AS p
                ON s.primarycontactpersonid = p.personid
            WHERE CONCAT(s.suppliername, ' ', p.fullname, ' ', p.preferredname)
                  LIKE '%' || p_search_text || '%'
            ORDER BY s.suppliername
            LIMIT p_maximum_rows_to_return
        ) t
    );
END;
$$ LANGUAGE plpgsql;
