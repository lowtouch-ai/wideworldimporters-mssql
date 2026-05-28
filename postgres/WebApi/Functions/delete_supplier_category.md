# Conversion summary: WebApi.DeleteSupplierCategory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplierCategory.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_supplier_category.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_supplier_category(p_supplier_category_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SupplierCategoryID int` | `p_supplier_category_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteSupplierCategory]` → `webapi.delete_supplier_category`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
