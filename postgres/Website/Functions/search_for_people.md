# search_for_people

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForPeople.sql`

## Summary

Returns a filtered list of people matching a search string, including their relationship (salesperson/employee/customer/supplier) and company name.

## Conversion notes

- `SELECT TOP(@n) ... FOR JSON AUTO, ROOT('People')` → `RETURNS TABLE(...) ... LIMIT p_MaximumRowsToReturn`
- `CASE WHEN p.IsSalesperson <> 0` → `CASE WHEN p.IsSalesperson` (boolean)
- `CASE WHEN p.IsEmployee <> 0` → `CASE WHEN p.IsEmployee`
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `LIKE N'%' + @SearchText + N'%'` → `ILIKE '%' || p_SearchText || '%'`

## Dependencies

| Object | Status |
|---|---|
| `application.people` | check postgres/Application/Tables/People.sql |
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
| `purchasing.suppliers` | check postgres/Purchasing/Tables/Suppliers.sql |
