# Conversion summary: WebApi.DeleteStateProvince

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStateProvince.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_state_province.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_state_province(p_state_province_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@StateProvinceID int` | `p_state_province_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteStateProvince]` → `webapi.delete_state_province`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
