# Conversion summary: WebApi.UpdateColorFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateColorFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_color_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_color_from_json(p_color text, p_color_id integer, p_user_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Color nvarchar(MAX)` | `p_color text` | text | JSON object payload |
| `@ColorID int` | `p_color_id integer` | integer | PK to update |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- Direct assignment, `jsonb_to_record`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` |
