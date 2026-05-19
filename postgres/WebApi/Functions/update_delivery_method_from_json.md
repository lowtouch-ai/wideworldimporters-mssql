# Conversion summary: WebApi.UpdateDeliveryMethodFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateDeliveryMethodFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_delivery_method_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_delivery_method_from_json(p_delivery_method text, p_delivery_method_id integer, p_user_id integer) RETURNS void
```

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` |
