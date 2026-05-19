# Conversion summary: WebApi.DeleteSupplier

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplier.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_supplier.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_supplier(p_supplier_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SupplierID int` | `p_supplier_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteSupplier]` → `webapi.delete_supplier`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
