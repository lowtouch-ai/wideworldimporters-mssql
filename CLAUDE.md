# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

This is the [WideWorldImporters](https://github.com/Microsoft/sql-server-samples) sample OLTP database for SQL Server / Azure SQL, used as a source for conversion to PostgreSQL DDL. The primary ongoing work is migrating MSSQL DDL files to PostgreSQL-compatible SQL.

There are no build scripts, linters, or test runners in this repository. All source files are SQL DDL.

## Key workflow: MSSQL → PostgreSQL conversion

Use the custom slash command:

```
/mssql-to-postgres <file-or-folder>
```

- Convert a single file: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql`
- Convert a whole schema: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables`

The command specification lives in `.claude/commands/mssql-to-postgres.md`. It defines all conversion rules — consult it directly for the full mapping logic rather than re-deriving rules ad hoc.

## Directory structure

| Path | Purpose |
|---|---|
| `wwi-ssdt/wwi-ssdt/<Schema>/` | MSSQL DDL source (authoritative) |
| `postgres/<Schema>/` | PostgreSQL DDL output (mirrors source tree) |
| `.claude/commands/` | Custom slash command definitions |
| `sample-scripts/` | Standalone T-SQL example scripts |
| `workload-drivers/` | C# workload simulation apps |
| `wwi-dw-ssdt/` | OLAP data warehouse DDL (separate SSDT project) |

## Source schema inventory (`wwi-ssdt/wwi-ssdt/`)

| Schema | Object types present |
|---|---|
| `Application` | Tables (10), Functions (1), Stored Procedures (15) |
| `Sales` | Tables (3) |
| `Purchasing` | Tables (3) |
| `Warehouse` | Tables (5) |
| `WebApi` | Stored Procedures (45), Views (2) |
| `Website` | Functions (7), Stored Procedures (8), Views (5), UDTs (4) |
| `Integration` | Stored Procedures (13) |
| `DataLoadSimulation` | Tables (9), Functions (4), Stored Procedures (6) |
| `Sequences` | 26 sequence objects + 2 stored procedures |
| `Security` | Role/permission scripts (22 files) |
| `PostDeploymentScripts` | Data population scripts (51 files) |
| `Storage` | Filegroups, partitions, indexes (6 files) |

## MSSQL features requiring special handling

- **Temporal tables**: Tables with `PERIOD FOR SYSTEM_TIME` and paired `_Archive` tables. Strip temporal clauses; convert `GENERATED ALWAYS AS ROW START/END` columns to plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`.
- **Sequences**: `[Sequences].[FooID]` → sequence object `sequences.foo_id_seq` emitted before the consuming table.
- **Geography columns**: `[sys].[geography]` → PostGIS `geography`. Requires `CREATE EXTENSION IF NOT EXISTS postgis;` at deployment.
- **Columnstore indexes**: No PostgreSQL equivalent — omit with a comment.
- **Extended properties** (`sp_addextendedproperty`): Index-level → omit; table-level → `COMMENT ON TABLE`; column-level → `COMMENT ON COLUMN`.

## Conversion output conventions

- Schema and table names: **lowercase** (`sales.orders`)
- Column names: **preserve original casing** (`OrderID`, `CustomerPurchaseOrderNumber`)
- Each output file starts with `CREATE SCHEMA IF NOT EXISTS <schema>;`
- Output path mirrors source: `wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql` → `postgres/Sales/Tables/Orders.sql`
- Each conversion also produces a companion `<Table>.md` in the same output directory (e.g. `postgres/Sales/Tables/Orders.md`) containing the conversion summary and unresolved dependency table.
- After each conversion, report FK dependencies that still lack a converted postgres file.
