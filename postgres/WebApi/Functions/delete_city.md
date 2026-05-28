# Conversion summary: WebApi.DeleteCity

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCity.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_city.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_city(p_city_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CityID int` | `p_city_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteCity]` → `webapi.delete_city`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
