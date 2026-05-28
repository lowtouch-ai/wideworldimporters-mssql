# Conversion summary: WebApi.UpdateStateProvinceFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateStateProvinceFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_state_province_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_state_province_from_json(p_state_province text, p_state_province_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StateProvince nvarchar(MAX)` | `p_state_province text` | text | JSON payload |
| `@StateProvinceID int` | `p_state_province_id integer` | integer | PK filter |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON … WITH (…)` → `jsonb_to_recordset(p_state_province::jsonb) AS json(…)` with snake_case aliases
- `strict $` path specifier removed (not supported in PostgreSQL JSON functions)
- Column names preserved with double-quotes in the UPDATE SET clause

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.stateprovinces` | `postgres/Application/Tables/StateProvinces.sql` |
