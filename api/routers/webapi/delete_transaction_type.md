# Conversion summary: WebApi.DeleteTransactionType

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteTransactionType.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/transaction-types/{transaction_type_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `application.transaction_types` | `postgres/Application/Tables/TransactionTypes.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@TransactionTypeID int` | Path param `transaction_type_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Application].[TransactionTypes] WHERE TransactionTypeID = @TransactionTypeID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
