# Conversion summary: WebApi.DeleteCountry

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCountry.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_country.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_country(p_country_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CountryID int` | `p_country_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteCountry]` → `webapi.delete_country`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
