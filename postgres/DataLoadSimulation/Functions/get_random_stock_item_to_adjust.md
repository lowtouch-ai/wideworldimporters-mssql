# Conversion summary: DataLoadSimulation.GetRandomStockItemToAdjust

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomStockItemToAdjust.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_stock_item_to_adjust.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_stock_item_to_adjust(p_quantity_to_adjust integer) RETURNS integer
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@QuantityToAdjust INT` | `p_quantity_to_adjust integer` | integer | Input |
| `@StockItemIDToAdjust INT OUTPUT` | return value | integer | OUTPUT → scalar return |

## Conversion notes
- `SELECT TOP(1) @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_id ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
