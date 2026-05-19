# Conversion summary: WebApi.InsertSupplierCategoriesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertSupplierCategoriesFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_supplier_categories_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_supplier_categories_from_json(p_supplier_categories text, p_user_id integer) RETURNS TABLE(suppliercategoryid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SupplierCategories nvarchar(MAX)` | `p_supplier_categories text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.SupplierCategoryID → RETURNING supplier_categories.suppliercategoryid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.supplier_categories` | `postgres/Purchasing/Tables/SupplierCategories.sql` |
