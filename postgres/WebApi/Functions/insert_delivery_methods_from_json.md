# Conversion summary: WebApi.InsertDeliveryMethodsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertDeliveryMethodsFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_delivery_methods_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_delivery_methods_from_json(p_delivery_methods text, p_user_id integer) RETURNS TABLE(deliverymethodid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@DeliveryMethods nvarchar(MAX)` | `p_delivery_methods text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.DeliveryMethodID → RETURNING delivery_methods.deliverymethodid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` |
