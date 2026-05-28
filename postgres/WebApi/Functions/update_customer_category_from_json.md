# Conversion summary: WebApi.UpdateCustomerCategoryFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateCustomerCategoryFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_customer_category_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_customer_category_from_json(p_customer_category text, p_customer_category_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CustomerCategory nvarchar(MAX)` | `p_customer_category text` | text | JSON object payload |
| `@CustomerCategoryID int` | `p_customer_category_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` |
