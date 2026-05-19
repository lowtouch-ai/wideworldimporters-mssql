# Conversion summary: WebApi.SearchForStockItems

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/SearchForStockItems.sql`
- **Pattern:** Search / Query
- **HTTP:** GET `/web-api/stock-items/search` → 200

## Tables/views referenced
| Object | Postgres file | Status |
|---|---|---|
| `webapi.stock_items` (view) | `postgres/WebApi/Views/stock_items.sql` | Converted |
| `warehouse.stockitemstockgroups` | `postgres/Warehouse/Tables/StockItemStockGroups.sql` | Converted |

## Parameter mapping
| SP Parameter | Endpoint parameter | Type | Notes |
|---|---|---|---|
| `@Name nvarchar(100)` | Query param `name: Optional[str]` | str | ILIKE `%name%` |
| `@Tag nvarchar(100)` | Query param `tag: Optional[str]` | str | JSON tag match |
| `@MinPrice decimal(18,2)` | Query param `min_price: Optional[float]` (alias `minPrice`) | float | Exclusive lower bound |
| `@MaxPrice decimal(18,2)` | Query param `max_price: Optional[float]` (alias `maxPrice`) | float | Exclusive upper bound |
| `@StockGroupID int` | Query param `stock_group_id: Optional[int]` (alias `stockGroupId`) | int | FK to stock_groups |
| `@MaximumRowsToReturn int` | Query param `maximum_rows_to_return: int` (alias `maximumRowsToReturn`) | int | Default 100 |

## SQL construct conversions
- `LIKE '%' + @Name + '%'` → `ILIKE :name_pattern` with `f"%{name}%"`
- `OPENJSON(CustomFields, '$.Tags') WITH (Tag NVARCHAR(20) '$')` → `jsonb_array_elements_text(("CustomFields"::jsonb)->'Tags')`
- `CROSS APPLY OPENJSON(...)` → `CROSS JOIN LATERAL jsonb_array_elements_text(...)`
- `SELECT TOP(@MaximumRowsToReturn) ... FOR JSON PATH` → `json_agg(row_to_json(v)) ... LIMIT :max_rows`
- `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` (outer) → single-row `SELECT` returning `{"value": [...], "tags": [...]}`
- `WebApi.StockItems` (view reference) → `webapi.stock_items`

## Warnings / manual review items
- TODO: verify JSON shape of `value` and `tags` keys matches original FOR JSON PATH, WITHOUT_ARRAY_WRAPPER output exactly.
- The `tags` aggregation flattens all tag values across the filtered result set (matching original CROSS APPLY behavior).
- If `CustomFields` is NULL for a row, `jsonb_array_elements_text` will produce no rows for that row — this matches MSSQL OPENJSON behavior on NULL.
