# Conversion summary: Storage — Partition Functions and Schemes

## Sources
- `wwi-ssdt/wwi-ssdt/Storage/PF_TransactionDate.sql`
- `wwi-ssdt/wwi-ssdt/Storage/PF_TransactionDateTime.sql`
- `wwi-ssdt/wwi-ssdt/Storage/PS_TransactionDate.sql`
- `wwi-ssdt/wwi-ssdt/Storage/PS_TransactionDateTime.sql`

## Output
- `postgres/Storage/partitioning.sql`

## Conversion notes

### Partition functions (PF_TransactionDate, PF_TransactionDateTime)
- **MSSQL:** `CREATE PARTITION FUNCTION … AS RANGE RIGHT FOR VALUES (…)` — a named, reusable partitioning rule
- **PostgreSQL:** No equivalent schema-level object. Partitioning is declared inline on the table with `PARTITION BY RANGE (column)` and child tables with `FOR VALUES FROM … TO …`
- **Boundaries:** `'2014-01-01'`, `'2015-01-01'`, `'2016-01-01'`, `'2017-01-01'` → 5 partitions (RANGE RIGHT means the boundary value belongs to the right/upper partition)
- **Type mapping:** `DATE` → `date`; `DATETIME` → `timestamptz`

### Partition schemes (PS_TransactionDate, PS_TransactionDateTime)
- **MSSQL:** `CREATE PARTITION SCHEME … AS PARTITION [PF_…] TO ([USERDATA], …)` — maps each partition to a filegroup
- **PostgreSQL:** No equivalent. Child partition tables inherit the parent's tablespace; per-partition storage placement requires specifying `TABLESPACE` on individual child tables

### No executable DDL
Both the partition functions and schemes are converted to documentation only. The working SQL is embedded as commented-out sample DDL in `partitioning.sql`, showing how to recreate equivalent year-range partitioning using PostgreSQL declarative partitioning.

## TODOs
- **Manual DDL migration:** To partition `warehouse.stockitemtransactions` (the primary table that used `PS_TransactionDateTime` in MSSQL), recreate it with `PARTITION BY RANGE ("TransactionOccurredWhen")` and add child tables for each year range. Sample DDL is provided (commented out) in `partitioning.sql`.
- **Other candidate tables:** Any table in the MSSQL source that referenced `PS_TransactionDate` or `PS_TransactionDateTime` via `ON [PS_TransactionDate](column)` needs to be evaluated and, if needed, recreated as a partitioned table.
- See also: `postgres/Application/Functions/configuration_apply_partitioning.sql` — the no-op stub that documents this limitation at the application function level.
