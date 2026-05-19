# search_for_customers

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForCustomers.sql`

## Summary

Returns a filtered list of customers matching a search string against customer name and primary contact name/preferred name fields.

## Conversion notes

- `SELECT TOP(@n) ... FOR JSON AUTO, ROOT('Customers')` → `RETURNS TABLE(...) ... RETURN QUERY SELECT ... LIMIT p_MaximumRowsToReturn`
- `FOR JSON AUTO, ROOT(N'Customers')` removed — function returns rows; callers can use `json_agg(row_to_json(t))` to get JSON
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `LIKE N'%' + @SearchText + N'%'` → `ILIKE '%' || p_SearchText || '%'` (case-insensitive; adjust to `LIKE` if case-sensitive match needed)
- Schema references lowercased

## Dependencies

| Object | Status |
|---|---|
| `sales.customers` | check postgres/Sales/Tables/Customers.sql |
| `application.cities` | check postgres/Application/Tables/Cities.sql |
| `application.people` | check postgres/Application/Tables/People.sql |
