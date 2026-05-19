# Conversion summary: WebApi.DeleteCountry

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCountry.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/countries/{country_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.countries` | `postgres/Application/Tables/Countries.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@CountryID int` | Path param `country_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[Countries] WHERE CountryID = @CountryID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
