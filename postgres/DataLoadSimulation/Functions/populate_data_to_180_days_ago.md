# Conversion summary: DataLoadSimulation.PopulateDataTo180DaysAgo

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateDataTo180DaysAgo.sql`
- **Pattern:** Simple DML (wrapper calling DailyProcessToCreateHistory)
- **Output:** `postgres/DataLoadSimulation/Functions/populate_data_to_180_days_ago.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.populate_data_to_180_days_ago(p_average_number_of_customer_orders_per_day integer DEFAULT 30, p_saturday_percentage_of_normal_work_day integer DEFAULT 25, p_sunday_percentage_of_normal_work_day integer DEFAULT 0, p_is_silent_mode boolean DEFAULT false, p_are_dates_printed boolean DEFAULT true) RETURNS void
```

## Conversion notes
- `CAST(DATEADD(day, -1, SYSDATETIME()) AS date)` → `CAST(CURRENT_TIMESTAMP AS date) - 1`
- All DEFAULT parameter values preserved

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
