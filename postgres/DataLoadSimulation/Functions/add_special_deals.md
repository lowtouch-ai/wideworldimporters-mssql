# Conversion summary: DataLoadSimulation.AddSpecialDeals

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddSpecialDeals.sql`
- **Pattern:** Simple DML (date-conditional INSERT)
- **Output:** `postgres/DataLoadSimulation/Functions/add_special_deals.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.add_special_deals(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CurrentDateTime datetime2(7)` | `p_current_date_time timestamp` | timestamp | |
| `@StartingWhen datetime` | `p_starting_when timestamp` | timestamp | |
| `@EndOfTime datetime2(7)` | `p_end_of_time timestamp` | timestamp | |
| `@IsSilentMode bit` | `p_is_silent_mode boolean` | boolean | |

## Conversion notes
- `CAST(@CurrentDateTime AS date) = '20211231'` → `CAST(p_current_date_time AS date) = '2021-12-31'`
- Inline subqueries to resolve foreign-key lookups preserved unchanged

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.specialdeals` | `postgres/Sales/Tables/SpecialDeals.sql` |
| `warehouse.stockgroups` | `postgres/Warehouse/Tables/StockGroups.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
