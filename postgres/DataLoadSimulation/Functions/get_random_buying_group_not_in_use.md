# Conversion summary: DataLoadSimulation.GetRandomBuyingGroupNotInUse

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomBuyingGroupNotInUse.sql`
- **Pattern:** Multi-value OUTPUT parameters with WHILE loop → RETURNS TABLE(10 columns)
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_buying_group_not_in_use.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_buying_group_not_in_use()
RETURNS TABLE(city_id integer, city_name varchar(50), state_province_code varchar(5),
              state_province_name varchar(50), area_code varchar(4), buying_group_id integer,
              buying_group_name varchar(50), web_domain varchar(256), email_domain varchar(256),
              customer_name varchar(100))
```

## Conversion notes
- `EXEC DataLoadSimulation.GetRandomCity @x = @x OUTPUT` → `SELECT r.* INTO vars FROM dataloadsimulation.get_random_city() r`
- `EXEC DataLoadSimulation.GetRandomBuyingGroup` → `SELECT r.* INTO vars FROM dataloadsimulation.get_random_buying_group() r`
- `[DataLoadSimulation].[GetCustomerCount](name)` → `dataloadsimulation.get_customer_count(name)` (already a function)
- `EXEC DataLoadSimulation.GetBuyingGroupDomain` → `SELECT r.* INTO vars FROM dataloadsimulation.get_buying_group_domain(name) r`
- `WHILE @InUseCounter > 0` → `WHILE v_in_use_counter > 0 LOOP`
- `RETURN 0` (void context) → removed
- Uses `RETURN NEXT` pattern for single-row TABLE return

## TODOs
None.

## Tables referenced
Delegates to other `dataloadsimulation` functions; no direct table access.
