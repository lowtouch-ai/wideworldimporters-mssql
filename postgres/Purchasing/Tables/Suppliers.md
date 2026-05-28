# Conversion summary: Suppliers.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Purchasing/Tables/Suppliers.sql`
- **Output:** `postgres/Purchasing/Tables/Suppliers.sql`

## Conversions applied
- `[Purchasing].[Suppliers]` → `purchasing.suppliers`
- `INT` → `INTEGER`
- `NVARCHAR(100)` → `VARCHAR(100)`, `NVARCHAR(50)` → `VARCHAR(50)`, `NVARCHAR(20)` → `VARCHAR(20)`, `NVARCHAR(60)` → `VARCHAR(60)`, `NVARCHAR(256)` → `VARCHAR(256)`, `NVARCHAR(10)` → `VARCHAR(10)`
- `NVARCHAR(MAX)` → `TEXT`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `[sys].[geography]` → `geography` (PostGIS)
- `MASKED WITH (FUNCTION = 'default()')` clauses stripped — no PostgreSQL equivalent for dynamic data masking
- `NEXT VALUE FOR [Sequences].[SupplierID]` → `nextval('sequences.supplier_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.supplier_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Purchasing_Suppliers_SupplierID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 6 `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 6 index-level extended properties → omitted (PostgreSQL does not support index comments via standard DDL)
- 1 table-level extended property → `COMMENT ON TABLE`
- 22 column-level extended properties → `COMMENT ON COLUMN`

All FK dependencies resolved (`application.people`, `application.cities`, `application.delivery_methods`, `purchasing.supplier_categories` all already converted).

## PostGIS note
This table uses PostGIS `geography` columns. Run `CREATE EXTENSION IF NOT EXISTS postgis;` before applying this file.
