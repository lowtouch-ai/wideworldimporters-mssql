# Conversion summary: DataLoadSimulation.GetRandomPaymentDays

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomPaymentDays.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_payment_days.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_payment_days() RETURNS integer
```

## Conversion notes
- `ABS(CHECKSUM(NEWID())) % 8` → `floor(random() * 8)::integer`
- CASE expression for weighted payment days (30, 45 appear more often) preserved as-is

## TODOs
None.

## Tables referenced
None.
