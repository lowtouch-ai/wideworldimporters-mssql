# Conversion summary: WebApi.DeleteSupplierCategory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplierCategory.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/supplier-categories/{supplier_category_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `purchasing.supplier_categories` | `postgres/Purchasing/Tables/SupplierCategories.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@SupplierCategoryID int` | Path param `supplier_category_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Purchasing].[SupplierCategories] WHERE SupplierCategoryID = @SupplierCategoryID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
