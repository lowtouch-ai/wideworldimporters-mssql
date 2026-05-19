# Conversion summary: WebApi.DeleteCustomerCategory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomerCategory.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_customer_category.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_customer_category(p_customer_category_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CustomerCategoryID int` | `p_customer_category_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteCustomerCategory]` → `webapi.delete_customer_category`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
