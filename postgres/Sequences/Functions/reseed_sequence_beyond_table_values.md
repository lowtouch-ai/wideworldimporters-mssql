# Conversion summary: Sequences.ReseedSequenceBeyondTableValues

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/Sequences/Stored Procedures/ReseedSequenceBeyondTableValues.sql`
- **Pattern:** Simple DML / void utility — no result set
- **Output:** `postgres/Sequences/Functions/reseed_sequence_beyond_table_values.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION sequences.reseed_sequence_beyond_table_values(
    p_sequence_name text,
    p_schema_name   text,
    p_table_name    text,
    p_column_name   text
) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@SequenceName sysname` | `p_sequence_name text` | `text` | `sysname` → `text` |
| `@SchemaName sysname` | `p_schema_name text` | `text` | |
| `@TableName sysname` | `p_table_name text` | `text` | |
| `@ColumnName sysname` | `p_column_name text` | `text` | |

## Conversion notes
- `sys.sequences.current_value` → `pg_sequences.last_value` (with `COALESCE(last_value, start_value)` because `last_value` is NULL before the sequence is first used)
- `CREATE TABLE #CurrentValue` / `INSERT #CurrentValue` pattern replaced by `EXECUTE format(...) INTO var` — no temp table needed
- `QUOTENAME(@col)` → `format('%I', p_column_name)` — `%I` provides safe identifier quoting
- `EXECUTE(@SQL)` → `EXECUTE format(...)` for the dynamic SELECT and ALTER SEQUENCE
- `SET NOCOUNT ON` / `SET XACT_ABORT ON` removed
- `DROP TABLE #CurrentValue` removed (temp table eliminated)

## TODOs
- **Caller must use PostgreSQL sequence names**: The MSSQL caller passes names like `'BuyingGroupID'`; the PG equivalents follow the pattern `buying_group_id_seq`. The converted `reseed_all_sequences` function uses the correct PG names. If calling this function ad-hoc, pass the PG sequence name (e.g., `'buying_group_id_seq'`).

## Tables / system objects referenced
| Object | Notes |
|---|---|
| `pg_sequences` | PostgreSQL catalog view replacing `sys.sequences` |
| Dynamic schema.table | Resolved at runtime via `format('%I.%I', ...)` |
