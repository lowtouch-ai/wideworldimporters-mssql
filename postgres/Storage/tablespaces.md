# Conversion summary: Storage — Filegroups

## Sources
- `wwi-ssdt/wwi-ssdt/Storage/USERDATA.sql`
- `wwi-ssdt/wwi-ssdt/Storage/WWI_MemoryOptimized_Data.sql`

## Output
- `postgres/Storage/tablespaces.sql`

## Conversion notes

### USERDATA filegroup
- **MSSQL:** `ALTER DATABASE ADD FILEGROUP [USERDATA]` — a named filegroup for application data
- **PostgreSQL:** `CREATE TABLESPACE` is the nearest equivalent but is optional; the default `pg_default` tablespace is sufficient unless storage separation is required
- **Action:** Emitted as a commented-out `CREATE TABLESPACE userdata` block with guidance; no executable DDL

### WWI_MemoryOptimized_Data filegroup
- **MSSQL:** `ALTER DATABASE ADD FILEGROUP [WWI_MemoryOptimized_Data] CONTAINS MEMORY_OPTIMIZED_DATA` — stores In-Memory OLTP (Hekaton) tables
- **PostgreSQL:** No equivalent DDL object exists. Memory-optimized workloads are addressed through:
  - `postgresql.conf`: `shared_buffers`, `huge_pages`, `effective_cache_size`
  - `UNLOGGED` tables (skip WAL, faster writes, data lost on crash)
- **Action:** No DDL emitted; documented in comments only

## TODOs
- If physical storage separation is required, uncomment `CREATE TABLESPACE userdata` in `tablespaces.sql` and set the correct `LOCATION` path for the target server.
- If any table definition references `ON [USERDATA]`, that clause is silently dropped in the PostgreSQL conversion (no equivalent; tables go to the default tablespace unless explicitly rerouted).
