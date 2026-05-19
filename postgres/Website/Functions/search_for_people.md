# Conversion summary: Website.SearchForPeople

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForPeople.sql`
- **Pattern:** Search/Query → `RETURNS jsonb`
- **Output:** `postgres/Website/Functions/search_for_people.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.search_for_people(
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
- `FOR JSON AUTO, ROOT(N'People')` → `json_build_object('People', json_agg(row_to_json(t)))`
- `TOP(@MaximumRowsToReturn)` → `LIMIT p_maximum_rows_to_return`
- `LIKE N'%' + @SearchText + N'%'` → `LIKE '%' || p_search_text || '%'`
- CASE expression: `IsSalesperson <> 0` → `"IsSalesperson"` (boolean column, no comparison needed)
- COALESCE for Company preserved as-is
- Two LEFT JOINs to Purchasing.Suppliers (sp + sa aliases) preserved

## TODOs
- Verify JSON shape matches original `FOR JSON AUTO, ROOT(N'People')` output

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` |
