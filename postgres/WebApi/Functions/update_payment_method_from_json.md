# Conversion summary: WebApi.UpdatePaymentMethodFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePaymentMethodFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_payment_method_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_payment_method_from_json(p_payment_method text, p_payment_method_id integer, p_user_id integer) RETURNS void
```

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` |
