# Conversion summary: DataLoadSimulation.AddCustomers

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/AddCustomers.sql`
- **Pattern:** Complex DML (WHILE loop with multiple helper calls + INSERT)
- **Output:** `postgres/DataLoadSimulation/Functions/add_customers.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.add_customers(p_current_date_time timestamp, p_starting_when timestamp, p_end_of_time timestamp, p_is_silent_mode boolean) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CurrentDateTime datetime2(7)` | `p_current_date_time timestamp` | timestamp | |
| `@StartingWhen datetime` | `p_starting_when timestamp` | timestamp | |
| `@EndOfTime datetime2(7)` | `p_end_of_time timestamp` | timestamp | |
| `@IsSilentMode bit` | `p_is_silent_mode boolean` | boolean | |

## Conversion notes
- `EXEC GetFicticiousName ... OUTPUT` → `SELECT INTO` from `dataloadsimulation.get_ficticious_name()`
- `EXEC GetRandomBuyingGroupNotInUse ... OUTPUT` → `SELECT INTO` from `dataloadsimulation.get_random_buying_group_not_in_use()`
- `NEXT VALUE FOR Sequences.CustomerID` → `nextval('sequences.customer_id_seq')`
- `NEXT VALUE FOR Sequences.PersonID` → `nextval('sequences.person_id_seq')`
- `[DataLoadSimulation].[GetCityLocation](@CityID)` → `dataloadsimulation.get_city_location(v_city_id)`
- `CEILING(RAND() * 30) * 100 + 1000` → `ceil(random() * 30)::integer * 100 + 1000`
- `bit` literals 0/1 → `false`/`true` for boolean columns
- `BEGIN TRAN/COMMIT` per customer removed (PostgreSQL wraps each function call in a transaction)
- `CAST(@StartingWhen AS date)` used for `AccountOpenedDate` (date column)

## TODOs
- None

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.people` | `postgres/Application/Tables/People.sql` |
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
