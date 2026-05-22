# Conversion summary: DataLoadSimulation.RecordInvoiceDeliveries

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/RecordInvoiceDeliveries.sql`
- **Pattern:** Cursor / complex DML with JSON and geography
- **Output:** `postgres/DataLoadSimulation/Functions/record_invoice_deliveries.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.record_invoice_deliveries(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Conversion notes
- `DECLARE InvoiceList CURSOR FAST_FORWARD READ_ONLY FOR ... WHILE @@FETCH_STATUS` → `FOR rec IN (...) LOOP`
- `ct.[Location].Lat` → `ST_Y(ct."Location"::geometry)` (PostGIS)
- `ct.[Location].Long` → `ST_X(ct."Location"::geometry)` (PostGIS)
- `JSON_MODIFY(@json, '$.Key', value)` → `jsonb_set(v_json, '{Key}', to_json(value)::jsonb)`
- `JSON_MODIFY(@json, 'append $.Events', JSON_QUERY(...))` → `jsonb_set(..., '{Events}', array || jsonb_build_array(event))`
- `DATEADD(minute, @Counter * 5, @StartingWhen)` → `p_starting_when + (v_counter * 5 * interval '1 minute')`
- `ReturnedDeliveryData` stored as text; cast jsonb→text on write

## TODOs
- Requires: `CREATE EXTENSION IF NOT EXISTS postgis;`

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.invoices` | `postgres/Sales/Tables/Invoices.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `application.cities` | `postgres/Application/Tables/Cities.sql` |
| `application.people` | `postgres/Application/Tables/People.sql` |
