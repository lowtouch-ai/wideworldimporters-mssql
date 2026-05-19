# Conversion summary: Website.SearchForCustomers

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Website/Stored Procedures/SearchForCustomers.sql`
- **Pattern:** Search/Query → `RETURNS jsonb`
- **Output:** `postgres/Website/Functions/search_for_customers.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.search_for_customers(
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
- `FOR JSON AUTO, ROOT(N'Customers')` → `json_build_object('Customers', json_agg(row_to_json(t)))` with COALESCE for empty result
- `TOP(@MaximumRowsToReturn)` → `LIMIT p_maximum_rows_to_return`
- `LIKE N'%' + @SearchText + N'%'` → `LIKE '%' || p_search_text || '%'`
- `LEFT OUTER JOIN` preserved as-is
- `CONCAT(...)` unchanged
- `WITH EXECUTE AS OWNER` removed

## TODOs
- Verify JSON shape matches original `FOR JSON AUTO, ROOT(N'Customers')` output

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
