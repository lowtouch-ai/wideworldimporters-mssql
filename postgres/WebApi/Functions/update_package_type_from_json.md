# Conversion summary: WebApi.UpdatePackageTypeFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePackageTypeFromJson.sql`
- **Pattern:** Update from JSON
- **Output:** `postgres/WebApi/Functions/update_package_type_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_package_type_from_json(p_package_type text, p_package_type_id integer, p_user_id integer) RETURNS void
```

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` |
