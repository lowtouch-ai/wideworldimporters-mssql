# Conversion summary: WebApi.InsertStateProvincesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertStateProvincesFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_state_provinces_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_state_provinces_from_json(p_state_provinces text, p_user_id integer) RETURNS TABLE(stateprovinceid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StateProvinces nvarchar(MAX)` | `p_state_provinces text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- Required fields (N'strict'): StateProvinceCode, StateProvinceName, CountryID, SalesTerritory
- `border` (geography) not in original SP — omitted
- `OUTPUT inserted.StateProvinceID → RETURNING state_provinces.stateprovinceid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` |
