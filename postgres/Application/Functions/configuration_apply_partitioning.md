# Conversion summary: Application.Configuration_ApplyPartitioning

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Application/Stored Procedures/Configuration_ApplyPartitioning.sql`
- **Pattern:** DDL management — no-op stub
- **Output:** `postgres/Application/Functions/configuration_apply_partitioning.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION application.configuration_apply_partitioning() RETURNS void
```

## Conversion notes
- `CREATE PARTITION FUNCTION PF_TransactionDateTime` and `CREATE PARTITION SCHEME` → no PostgreSQL equivalent
- `sys.partition_functions` catalog check removed
- PostgreSQL partitioning requires `PARTITION BY RANGE (column)` at `CREATE TABLE` time, not as a post-deployment procedure
- `SERVERPROPERTY(N'IsXTPSupported')` check removed
- No-op stub with guidance notice

## TODOs
- **Manual DDL migration**: To partition `warehouse.stockitemtransactions` or other high-volume tables by date, recreate them as `PARTITION BY RANGE ("TransactionOccurredWhen")` with monthly/quarterly child partitions.
