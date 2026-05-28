# Conversion summary: WebApi.SearchForStockItems

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/SearchForStockItems.sql`
- **Pattern:** Search / Query (complex JSON-wrapped result set)
- **Output:** `postgres/WebApi/Functions/search_for_stock_items.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.search_for_stock_items(
    p_name varchar(100),
    p_tag varchar(100),
    p_min_price numeric(18,2),
    p_max_price numeric(18,2),
    p_stock_group_id integer,
    p_maximum_rows_to_return integer
) RETURNS TABLE(result jsonb)
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@Name nvarchar(100)` | `p_name varchar(100)` | varchar(100) | Stock item name filter (LIKE) |
| `@Tag nvarchar(100)` | `p_tag varchar(100)` | varchar(100) | Tag filter (JSON array element) |
| `@MinPrice decimal(18,2)` | `p_min_price numeric(18,2)` | numeric(18,2) | Min unit price filter |
| `@MaxPrice decimal(18,2)` | `p_max_price numeric(18,2)` | numeric(18,2) | Max unit price filter |
| `@StockGroupID int` | `p_stock_group_id integer` | integer | Stock group filter |
| `@MaximumRowsToReturn int` | `p_maximum_rows_to_return integer` | integer | Result limit |

## Conversion notes
- `[WebApi].[SearchForStockItems]` → `webapi.search_for_stock_items`
- `WITH EXECUTE AS OWNER` removed
- CTE `WITH value AS (...)` preserved
- `WebApi.StockItems` → `webapi.stock_items` (view reference)
- `LIKE '%' + @Name + '%'` → `LIKE '%' || p_name || '%'`
- `TOP(@MaximumRowsToReturn)` → `LIMIT p_maximum_rows_to_return` (moved to end of subquery)
- `OPENJSON(CustomFields, '$.Tags') WITH (Tag NVARCHAR(20) '$')` → `jsonb_array_elements_text((CustomFields::jsonb)->'Tags') AS tag` (CustomFields is TEXT; cast to jsonb)
- `CROSS APPLY OPENJSON(...)` → `CROSS JOIN LATERAL jsonb_array_elements_text(...)`
- `EXISTS (SELECT * FROM OPENJSON(...) WHERE Tag = @Tag)` → `EXISTS (SELECT 1 FROM jsonb_array_elements_text(...) WHERE tag = p_tag)`
- `FOR JSON PATH` (value subquery) → `json_agg(row_to_json(v))`
- `FOR JSON PATH` (tags subquery) → `json_agg(row_to_json(tg))`
- `FOR JSON PATH, WITHOUT_ARRAY_WRAPPER` (outer) → `row_to_json(t)::jsonb`
- Return type is `TABLE(result jsonb)` — single row containing JSON object with `value` and `tags` keys

## TODOs
- `-- TODO: verify JSON shape matches original FOR JSON PATH, WITHOUT_ARRAY_WRAPPER output` — the result is a JSON object `{"value": [...], "tags": [...]}`. Verify the key names and column casing match what the original MSSQL FOR JSON PATH produced.

## Tables/Views referenced
| Object | Postgres file |
|---|---|
| `webapi.stock_items` (view) | `postgres/WebApi/Views/stock_items.sql` |
| `warehouse.stockitemstockgroups` | `postgres/Warehouse/Tables/StockItemStockGroups.sql` |
