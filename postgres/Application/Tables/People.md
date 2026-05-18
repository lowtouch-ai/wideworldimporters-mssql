# Conversion summary: People.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Application/Tables/People.sql`
- **Output:** `postgres/Application/Tables/People.sql`

## Conversions applied
- `[Application].[People]` → `application.people`
- `INT` → `INTEGER`
- `NVARCHAR(n)` → `VARCHAR(n)` (FullName, PreferredName, LogonName, UserPreferences, PhoneNumber, FaxNumber, EmailAddress, CustomFields)
- `NVARCHAR(MAX)` → `TEXT` (UserPreferences, CustomFields)
- `VARBINARY(MAX)` → `BYTEA` (HashedPassword, Photo)
- `BIT` → `BOOLEAN` (IsPermittedToLogon, IsExternalLogonProvider, IsSystemUser, IsEmployee, IsSalesperson)
- `NEXT VALUE FOR [Sequences].[PersonID]` → `nextval('sequences.person_id_seq')`; sequence emitted
- Named-default constraint removed
- `GENERATED ALWAYS AS ROW START` / `GENERATED ALWAYS AS ROW END` → `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PERIOD FOR SYSTEM_TIME (...)` / `WITH (SYSTEM_VERSIONING = ON ...)` removed
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `SearchName AS (concat(...)) PERSISTED NOT NULL` → `TEXT GENERATED ALWAYS AS (PreferredName || ' ' || FullName) STORED NOT NULL` (concat → || operator; concat is STABLE, not IMMUTABLE in PostgreSQL)
- `OtherLanguages AS (json_query(...))` non-persisted → `TEXT NULL` plain column with NOTE comment
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (4 indexes, including INCLUDE clause)
- 4 index-level extended properties → omitted
- 1 table-level + 18 column-level extended properties → `COMMENT ON TABLE` / `COMMENT ON COLUMN`
