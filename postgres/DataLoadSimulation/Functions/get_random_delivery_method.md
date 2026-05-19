# Conversion summary: DataLoadSimulation.GetRandomDeliveryMethod

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomDeliveryMethod.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_delivery_method.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_delivery_method() RETURNS integer
```

## Conversion notes
- Single OUTPUT parameter → scalar RETURNS integer
- `SELECT TOP (1) @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_id ... ORDER BY random() LIMIT 1`
- `ValidTo = '99991231 23:59:59.9999999'` → `'9999-12-31 23:59:59.999999'`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `application.deliverymethods` | `postgres/Application/Tables/DeliveryMethods.sql` |
