# Conversion summary: DataLoadSimulation.PopulateDataToCurrentDate

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateDataToCurrentDate.sql`
- **Pattern:** Simple DML (wrapper calling DailyProcessToCreateHistory)
- **Output:** `postgres/DataLoadSimulation/Functions/populate_data_to_current_date.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.populate_data_to_current_date(p_average_number_of_customer_orders_per_day integer, p_saturday_percentage_of_normal_work_day integer, p_sunday_percentage_of_normal_work_day integer, p_is_silent_mode boolean, p_are_dates_printed boolean) RETURNS void
```

## Conversion notes
- `CAST(DATEADD(day, -1, SYSDATETIME()) AS date)` → `CAST(CURRENT_TIMESTAMP AS date) - 1`
- No DEFAULT values (all parameters required, matching original)

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
