# Conversion summary: WebApi.DeletePackageType

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePackageType.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/package-types/{package_type_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `warehouse.package_types` | `postgres/Warehouse/Tables/PackageTypes.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@PackageTypeID int` | Path param `package_type_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Warehouse].[PackageTypes] WHERE PackageTypeID = @PackageTypeID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
