# Conversion summary: DataLoadSimulation.PerformStocktake

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PerformStocktake.sql`
- **Pattern:** Simple DML (WHILE loop with UPDATEs and INSERTs)
- **Output:** `postgres/DataLoadSimulation/Functions/perform_stocktake.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.perform_stocktake(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `CEILING(RAND() * N)` → `ceil(random() * N)::integer`
- Calls `dataloadsimulation.get_random_employee_person()` and `dataloadsimulation.get_random_stock_item_to_adjust()`
- Calls `dataloadsimulation.get_transaction_type_id('Stock Adjustment at Stocktake')`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `warehouse.stockitemholdings` | `postgres/Warehouse/Tables/StockItemHoldings.sql` |
| `warehouse.stockitemtransactions` | `postgres/Warehouse/Tables/StockItemTransactions.sql` |
