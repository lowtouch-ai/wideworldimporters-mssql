# Conversion summary: WebApi.DeleteColor

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteColor.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/colors/{color_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `warehouse.colors` | `postgres/Warehouse/Tables/Colors.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@ColorID int` | Path param `color_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Warehouse].[Colors] WHERE ColorID = @ColorID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
