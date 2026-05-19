# Conversion summary: WebApi.DeleteCustomer

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomer.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/customers/{customer_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@CustomerID int` | Path param `customer_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Sales].[Customers] WHERE CustomerID = @CustomerID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
