# Conversion summary: DataLoadSimulation.GetRandomCustomerCategory

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/GetRandomCustomerCategory.sql`
- **Pattern:** Single OUTPUT parameter → RETURNS integer
- **Output:** `postgres/DataLoadSimulation/Functions/get_random_customer_category.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_random_customer_category() RETURNS integer
```

## Conversion notes
- Single OUTPUT parameter → scalar RETURNS integer
- `SELECT TOP 1 @var = col ... ORDER BY NEWID()` → `SELECT col INTO v_id ... ORDER BY random() LIMIT 1`

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.customercategories` | `postgres/Sales/Tables/CustomerCategories.sql` |
