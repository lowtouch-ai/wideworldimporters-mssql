# search_for_suppliers

Converted from: `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForSuppliers.sql`

## Summary

Returns a filtered list of suppliers matching a search string against supplier name and primary contact name/preferred name fields.

## Conversion notes

- `SELECT TOP(@n) ... FOR JSON AUTO, ROOT('Suppliers')` → `RETURNS TABLE(...) ... LIMIT`
- `LEFT OUTER JOIN` → `LEFT JOIN`
- `LIKE N'%' + @SearchText + N'%'` → `ILIKE '%' || p_SearchText || '%'`

## Dependencies

| Object | Status |
|---|---|
| `purchasing.suppliers` | check postgres/Purchasing/Tables/Suppliers.sql |
| `application.cities` | check postgres/Application/Tables/Cities.sql |
| `application.people` | check postgres/Application/Tables/People.sql |
