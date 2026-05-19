# Conversion summary: WebApi.DeletePaymentMethod

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePaymentMethod.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_payment_method.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_payment_method(p_payment_method_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PaymentMethodID int` | `p_payment_method_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeletePaymentMethod]` → `webapi.delete_payment_method`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
