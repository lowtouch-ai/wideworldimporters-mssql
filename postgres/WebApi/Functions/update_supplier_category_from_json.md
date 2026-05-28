# Conversion summary: WebApi.UpdateSupplierCategoryFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSupplierCategoryFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_supplier_category_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_supplier_category_from_json(p_supplier_category text, p_supplier_category_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SupplierCategory nvarchar(MAX)` | `p_supplier_category text` | text | JSON payload |
| `@SupplierCategoryID int` | `p_supplier_category_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_supplier_category::jsonb) AS json(…)`
- Column names preserved with double-quotes in the UPDATE SET clause

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.suppliercategories` | `postgres/Purchasing/Tables/SupplierCategories.sql` |
