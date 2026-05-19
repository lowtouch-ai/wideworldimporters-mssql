# Conversion summary: DataLoadSimulation.GetStateProvinceID

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetStateProvinceID.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_state_province_id.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_state_province_id(p_state_province_code varchar(5)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@StateProvinceCode NVARCHAR(5)` | `p_state_province_code varchar(5)` | `varchar(5)` |

## Conversion notes
- `SELECT @SPId = StateProvinceID FROM Application.StateProvinces WHERE StateProvinceCode = @StateProvinceCode AND ValidTo = '99991231 23:59:59.9999999'` → `SELECT "StateProvinceID" INTO _sp_id FROM application.stateprovinces WHERE "StateProvinceCode" = p_state_province_code AND "ValidTo" = '9999-12-31 23:59:59.999999'`
- `ValidTo = '99991231 23:59:59.9999999'` → `"ValidTo" = '9999-12-31 23:59:59.999999'` (temporal table "current record" sentinel)

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
