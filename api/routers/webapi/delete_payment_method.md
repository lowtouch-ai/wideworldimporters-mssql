# Conversion summary: WebApi.DeletePaymentMethod

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeletePaymentMethod.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/payment-methods/{payment_method_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.payment_methods` | `postgres/Application/Tables/PaymentMethods.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@PaymentMethodID int` | Path param `payment_method_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[PaymentMethods] WHERE PaymentMethodID = @PaymentMethodID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
