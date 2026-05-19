# Conversion summary: WebApi.DeleteSupplier

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteSupplier.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/suppliers/{supplier_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `purchasing.suppliers` | `postgres/Purchasing/Tables/Suppliers.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@SupplierID int` | Path param `supplier_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Purchasing].[Suppliers] WHERE SupplierID = @SupplierID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
