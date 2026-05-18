# Conversion summary: Colors.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Warehouse/Tables/Colors.sql`
- **Output:** `postgres/Warehouse/Tables/Colors.sql`

## Conversions applied
- `[Warehouse].[Colors]` → `warehouse.colors`
- `INT` → `INTEGER`
- `NVARCHAR(20)` → `VARCHAR(20)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[ColorID]` → `nextval('sequences.color_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.color_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Warehouse_Colors_ColorID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 2 column-level extended properties → `COMMENT ON COLUMN`

All FK dependencies resolved (`application.people` already converted).
