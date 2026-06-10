# Conversion summary: People.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/People.sql`
- **Output:** `postgres/Application/Tables/People.sql`

## Conversions applied
- `[Application].[People]` → `application.people`
- `INT` → `INTEGER`
- `NVARCHAR(50/256)` → `VARCHAR(50/256)`
- `NVARCHAR(MAX)` → `TEXT`
- `BIT` → `BOOLEAN`
- `VARBINARY(MAX)` → `BYTEA`
- `NEXT VALUE FOR [Sequences].[PersonID]` → `nextval('sequences.person_id_seq')` + `CREATE SEQUENCE` emitted
- Temporal table handling: `GENERATED ALWAYS AS ROW START/END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`; `PERIOD FOR SYSTEM_TIME` and `SYSTEM_VERSIONING` clauses removed
- Persisted computed column: `concat([PreferredName], N' ', [FullName]) PERSISTED` → `GENERATED ALWAYS AS (PreferredName || ' ' || FullName) STORED` (rewritten to use `||` for IMMUTABLE expression)
- Non-persisted computed column: `json_query([CustomFields], N'$.OtherLanguages')` → plain nullable `TEXT` column with comment
- Named-default constraint syntax removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- 4 `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 4 index-level extended properties → omitted (indexes cannot have comments via standard DDL)
- 20 column-level and table-level extended properties → `COMMENT ON TABLE / COLUMN`

## PostGIS note
No geography columns in this table.
