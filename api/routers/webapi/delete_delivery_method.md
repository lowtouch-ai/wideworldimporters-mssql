# Conversion summary: WebApi.DeleteDeliveryMethod

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteDeliveryMethod.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/delivery-methods/{delivery_method_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.delivery_methods` | `postgres/Application/Tables/DeliveryMethods.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@DeliveryMethodID int` | Path param `delivery_method_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[DeliveryMethods] WHERE DeliveryMethodID = @DeliveryMethodID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
