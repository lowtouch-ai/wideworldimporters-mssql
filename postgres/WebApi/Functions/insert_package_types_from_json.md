# Conversion summary: WebApi.InsertPackageTypesFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/InsertPackageTypesFromJson.sql`
- **Pattern:** Insert with OUTPUT
- **Output:** `postgres/WebApi/Functions/insert_package_types_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.insert_package_types_from_json(p_package_types text, p_user_id integer) RETURNS TABLE(packagetypeid integer)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@PackageTypes nvarchar(MAX)` | `p_package_types text` | text | JSON array payload |
| `@UserID int` | `p_user_id integer` | integer | Audit user |

## Conversion notes
- `OPENJSON → jsonb_to_recordset`, `OUTPUT inserted.PackageTypeID → RETURNING package_types.packagetypeid`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` |
