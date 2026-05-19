# Conversion summary: WebApi.InsertCustomerCategoriesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertCustomerCategoriesFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_customer_categories_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_customer_categories_from_json(p_customer_categories text, p_user_id integer) RETURNS TABLE(customercategoryid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CustomerCategories nvarchar(MAX)` | `p_customer_categories text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.CustomerCategoryID → RETURNING customer_categories.customercategoryid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` |
