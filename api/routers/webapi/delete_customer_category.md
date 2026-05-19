# Conversion summary: WebApi.DeleteCustomerCategory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomerCategory.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/customer-categories/{customer_category_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `sales.customer_categories` | `postgres/Sales/Tables/CustomerCategories.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@CustomerCategoryID int` | Path param `customer_category_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Sales].[CustomerCategories] WHERE CustomerCategoryID = @CustomerCategoryID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
