# Conversion summary: WebApi.DeleteColor

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteColor.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_color.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_color(p_color_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@ColorID int` | `p_color_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteColor]` → `webapi.delete_color`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
