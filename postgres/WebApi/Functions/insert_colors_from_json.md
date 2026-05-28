# Conversion summary: WebApi.InsertColorsFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertColorsFromJson.sql`
- **Pattern:** Insert with OUTPUT (batch insert from JSON array, returns inserted IDs)
- **Output:** `postgres/WebApi/Functions/insert_colors_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_colors_from_json(p_colors text, p_user_id integer) RETURNS TABLE(colorid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Colors nvarchar(MAX)` | `p_colors text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON(@Colors) WITH (ColorName nvarchar(50))` → `jsonb_to_recordset(p_colors::jsonb) AS x("ColorName" varchar(50))`
- `OUTPUT inserted.ColorID` → `RETURNING colors.colorid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` |
