# Conversion summary: WebApi.DeleteCity

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCity.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/cities/{city_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.cities` | `postgres/Application/Tables/Cities.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@CityID int` | Path param `city_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[Cities] WHERE CityID = @CityID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
