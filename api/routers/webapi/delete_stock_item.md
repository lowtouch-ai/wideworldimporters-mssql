# Conversion summary: WebApi.DeleteStockItem

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockItem.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/stock-items/{stock_item_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@StockItemID int` | Path param `stock_item_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Warehouse].[StockItems] WHERE StockItemID = @StockItemID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
