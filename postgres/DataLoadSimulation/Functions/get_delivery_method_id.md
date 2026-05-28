# Conversion summary: DataLoadSimulation.GetDeliveryMethodID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetDeliveryMethodID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_delivery_method_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_delivery_method_id(p_delivery_method_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@DeliveryMethodName NVARCHAR(50)` | `p_delivery_method_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT TOP 1 @DelivMethodId = DeliveryMethodID FROM Application.DeliveryMethods WHERE ... AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT "DeliveryMethodID" INTO _deliv_method_id FROM application.deliverymethods WHERE ... AND "ValidTo" = '9999-12-31 23:59:59.999999' LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel, timestamp(6) precision)
- `NVARCHAR(50)` → `varchar(50)`

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.deliverymethods` | `postgres/Application/Tables/DeliveryMethods.sql` |
