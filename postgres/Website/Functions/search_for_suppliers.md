# Conversion summary: Website.SearchForSuppliers

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForSuppliers.sql`
- **Pattern:** Search/Query → `RETURNS jsonb`
- **Output:** `postgres/Website/Functions/search_for_suppliers.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.search_for_suppliers(
    p_search_text varchar(1000),
    p_maximum_rows_to_return integer
) RETURNS jsonb
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SearchText nvarchar(1000)` | `p_search_text varchar(1000)` | varchar(1000) | |
| `@MaximumRowsToReturn int` | `p_maximum_rows_to_return integer` | integer | |

## Conversion notes
- `FOR JSON AUTO, ROOT(N'Suppliers')` → `json_build_object('Suppliers', json_agg(row_to_json(t)))`
- `TOP(@MaximumRowsToReturn)` → `LIMIT p_maximum_rows_to_return`
- `LIKE N'%' + @SearchText + N'%'` → `LIKE '%' || p_search_text || '%'`
- `CONCAT(...)` preserved as-is
- `LEFT OUTER JOIN` preserved

## TODOs
- Verify JSON shape matches original `FOR JSON AUTO, ROOT(N'Suppliers')` output

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
