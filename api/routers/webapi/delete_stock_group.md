# Conversion summary: WebApi.DeleteStockGroup

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteStockGroup.sql`
- **Pattern:** Simple DELETE
- **HTTP:** DELETE `/web-api/stock-groups/{stock_group_id}` → 204 No Content / 404

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `warehouse.stock_groups` | `postgres/Warehouse/Tables/StockGroups.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@StockGroupID int` | Path param `stock_group_id: int` | int | Primary key |

## SQL construct conversions
- `DELETE FROM [Warehouse].[StockGroups] WHERE StockGroupID = @StockGroupID` → parameterized `text()` with `:id`
- `@@ROWCOUNT = 0` → `result.rowcount == 0` → `HTTPException(404)`
