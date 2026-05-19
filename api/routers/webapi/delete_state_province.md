# Conversion summary: WebApi.DeleteStateProvince

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStateProvince.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/state-provinces/{state_province_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.state_provinces` | `postgres/Application/Tables/StateProvinces.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@StateProvinceID int` | Path param `state_province_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[StateProvinces] WHERE StateProvinceID = @StateProvinceID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
