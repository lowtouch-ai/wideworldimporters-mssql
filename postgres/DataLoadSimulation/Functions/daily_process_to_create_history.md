# Conversion summary: DataLoadSimulation.DailyProcessToCreateHistory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/DailyProcessToCreateHistory.sql`
- **Pattern:** Complex orchestration (main simulation loop calling ~14 sub-functions)
- **Output:** `postgres/DataLoadSimulation/Functions/daily_process_to_create_history.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.daily_process_to_create_history(p_start_date date, p_end_date date, p_average_number_of_customer_orders_per_day integer DEFAULT 30, p_saturday_percentage_of_normal_work_day integer, p_sunday_percentage_of_normal_work_day integer, p_update_custom_fields boolean, p_is_silent_mode boolean, p_are_dates_printed boolean, p_min_yearly_growth_percent integer DEFAULT -5, p_max_yearly_growth_percent integer DEFAULT 15, p_min_seasonal_variation_percent integer DEFAULT -10, p_max_seasonal_variation_percent integer DEFAULT 30, p_max_daily_variation_percent integer DEFAULT 20) RETURNS void
```

## Conversion notes
- `SET DATEFIRST 7; DATEPART(weekday, ...) IN (1, 7)` → `EXTRACT(DOW FROM ...) IN (0, 6)` (0=Sun, 6=Sat in PostgreSQL)
- `DATEPART(weekday, ...) = 2` (Monday in MSSQL DATEFIRST 7) → `v_weekday = 1` (Monday in PG DOW)
- `DATEPART(weekday, ...) = 1` (Sunday) → `v_weekday = 0`; `= 7` (Saturday) → `v_weekday = 6`
- `DATEPART(year/month/day, ...)` → `EXTRACT(YEAR/MONTH/DAY FROM ...)::integer`
- `DATEFROMPARTS(y, m, d)` → `make_date(y, m, d)`
- `DATEDIFF(DAY, date1, date2)` → `(date2 - date1)` (integer result for date subtraction)
- `SUBSTRING(DATENAME(weekday, date), 1, 3)` → `SUBSTRING(to_char(date, 'Day'), 1, 3)`
- `CONVERT(nvarchar(20), date, 107)` → `to_char(date, 'Mon DD, YYYY')`
- `BEGIN TRY / BEGIN CATCH ... IF XACT_STATE() ROLLBACK; THROW` → `BEGIN ... EXCEPTION WHEN OTHERS THEN ... RAISE`
- All `EXEC DataLoadSimulation.X` → `PERFORM dataloadsimulation.x(...)`
- `EXEC Sequences.ReseedAllSequences` → `PERFORM sequences.reseed_all_sequences()`
- `EXEC Application.Configuration_ApplyRowLevelSecurity` → `PERFORM application.configuration_apply_row_level_security()`
- `@IsStaffOnly bit` declared but never used in original — omitted
- `DECLARE @x float` inside WHILE loop in original → moved to DECLARE section
- `SIN(2 * 3.1415926 * (@x - 0.25))` → `SIN(2.0 * 3.1415926 * (v_x - 0.25))` (PostgreSQL uses double precision)
- `'99991231 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'` (6 decimal places for timestamp(6))

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
| `dataloadsimulation.seasonvariation` | `postgres/DataLoadSimulation/Tables/SeasonVariation.sql` |

## Sub-functions called
- `dataloadsimulation.deactivate_temporal_tables_before_data_load()`
- `dataloadsimulation.receive_purchase_orders(...)`
- `dataloadsimulation.change_passwords(...)`
- `dataloadsimulation.activate_website_logons(...)`
- `dataloadsimulation.pay_suppliers(...)`
- `dataloadsimulation.create_customer_orders(...)`
- `dataloadsimulation.pick_stock_for_customer_orders(...)`
- `dataloadsimulation.process_customer_payments(...)`
- `dataloadsimulation.invoice_picked_orders(...)`
- `dataloadsimulation.place_supplier_orders(...)`
- `dataloadsimulation.perform_stocktake(...)`
- `dataloadsimulation.record_invoice_deliveries(...)`
- `dataloadsimulation.add_customers(...)`
- `dataloadsimulation.add_stock_items(...)`
- `dataloadsimulation.add_special_deals(...)`
- `dataloadsimulation.make_temporal_changes(...)`
- `dataloadsimulation.record_delivery_van_temperatures(...)`
- `dataloadsimulation.record_cold_room_temperatures(...)`
- `dataloadsimulation.update_custom_fields(...)`
- `dataloadsimulation.reactivate_temporal_tables_after_data_load()`
- `sequences.reseed_all_sequences()`
- `application.configuration_apply_row_level_security()`
