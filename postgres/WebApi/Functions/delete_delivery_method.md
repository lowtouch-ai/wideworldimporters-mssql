# Conversion summary: WebApi.DeleteDeliveryMethod

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteDeliveryMethod.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_delivery_method.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_delivery_method(p_delivery_method_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@DeliveryMethodID int` | `p_delivery_method_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteDeliveryMethod]` → `webapi.delete_delivery_method`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
