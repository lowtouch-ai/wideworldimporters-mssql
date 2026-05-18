# Conversion summary: Customers.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql`
- **Output:** `postgres/Sales/Tables/Customers.sql`

## Conversions applied
- `[Sales].[Customers]` → `sales.customers`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`, `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(5)` → `VARCHAR(5)`, `NVARCHAR(256)` → `VARCHAR(256)`, `NVARCHAR(60)` → `VARCHAR(60)`, `NVARCHAR(10)` → `VARCHAR(10)`
- `DECIMAL(18,2)` → `NUMERIC(18,2)`, `DECIMAL(18,3)` → `NUMERIC(18,3)`
- `BIT` → `BOOLEAN`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `[sys].[geography]` → `geography` (PostGIS)
- `NEXT VALUE FOR [Sequences].[CustomerID]` → `nextval('sequences.customer_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS` emitted
- Named-default constraint syntax removed (`CONSTRAINT [DF_...] DEFAULT (...)`)
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` clause dropped; `ValidFrom`/`ValidTo` converted to plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- 8 × `CREATE NONCLUSTERED INDEX` → `CREATE INDEX` (1 with `INCLUDE` clause preserved)
- 8 index-level extended properties → omitted (with comment)
- 1 table-level extended property → `COMMENT ON TABLE`
- 28 column-level extended properties → `COMMENT ON COLUMN`

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
