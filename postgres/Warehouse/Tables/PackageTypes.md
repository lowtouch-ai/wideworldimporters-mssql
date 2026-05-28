# Conversion summary: PackageTypes.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/PackageTypes.sql`
- **Output:** `postgres/Warehouse/Tables/PackageTypes.sql`

## Conversions applied
- `[Warehouse].[PackageTypes]` → `warehouse.package_types`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[PackageTypeID]` → `nextval('sequences.package_type_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.package_type_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Warehouse_PackageTypes_PackageTypeID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 2 column-level extended properties → `COMMENT ON COLUMN`

All FK dependencies resolved (`application.people` already converted).
