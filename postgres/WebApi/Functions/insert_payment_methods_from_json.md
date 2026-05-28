# Conversion summary: WebApi.InsertPaymentMethodsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPaymentMethodsFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_payment_methods_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_payment_methods_from_json(p_payment_methods text, p_user_id integer) RETURNS TABLE(paymentmethodid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PaymentMethods nvarchar(MAX)` | `p_payment_methods text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.PaymentMethodID → RETURNING payment_methods.paymentmethodid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` |
