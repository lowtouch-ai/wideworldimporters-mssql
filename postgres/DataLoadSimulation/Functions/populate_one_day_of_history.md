# Conversion summary: DataLoadSimulation.PopulateOneDayOfHistory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/PopulateOneDayOfHistory.sql`
- **Pattern:** Simple DML (wrapper calling DailyProcessToCreateHistory)
- **Output:** `postgres/DataLoadSimulation/Functions/populate_one_day_of_history.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.populate_one_day_of_history(p_average_number_of_customer_orders_per_day integer DEFAULT 30, p_saturday_percentage_of_normal_work_day integer DEFAULT 25, p_sunday_percentage_of_normal_work_day integer DEFAULT 0, p_is_silent_mode boolean DEFAULT false, p_are_dates_printed boolean DEFAULT true) RETURNS void
```

## Conversion notes
- `COALESCE((SELECT MAX(OrderDate) FROM Sales.Orders), '20191231')` → ISO date `'2019-12-31'`
- `DATEADD(day, 1, ...)` → `date + 1`
- `EXEC DataLoadSimulation.DailyProcessToCreateHistory` → `PERFORM dataloadsimulation.daily_process_to_create_history(...)`
- `@UpdateCustomFields = 0` → `p_update_custom_fields => false`

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
