# Conversion summary: WebApi.DeletePackageType

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePackageType.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_package_type.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_package_type(p_package_type_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PackageTypeID int` | `p_package_type_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeletePackageType]` → `webapi.delete_package_type`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
