# Conversion summary: BuyingGroups.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/BuyingGroups.sql`
- **Output:** `postgres/Sales/Tables/BuyingGroups.sql`

## Conversions applied
- `[Sales].[BuyingGroups]` → `sales.buying_groups`
- `INT` → `INTEGER`
- `NVARCHAR(50)` → `VARCHAR(50)`
- `DATETIME2(7)` → `TIMESTAMP(6)`
- `NEXT VALUE FOR [Sequences].[BuyingGroupID]` → `nextval('sequences.buying_group_id_seq')` + `CREATE SEQUENCE IF NOT EXISTS sequences.buying_group_id_seq` emitted
- Named-default constraint `CONSTRAINT [DF_Sales_BuyingGroups_BuyingGroupID] DEFAULT (...)` → `DEFAULT (...)`
- Temporal table: `PERIOD FOR SYSTEM_TIME` clause dropped; `WITH (SYSTEM_VERSIONING = ON ...)` dropped; `GENERATED ALWAYS AS ROW START/END` columns → plain `TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP`
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `UNIQUE NONCLUSTERED` → `UNIQUE`
- 1 table-level extended property → `COMMENT ON TABLE`
- 2 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `sales.buying_groups (LastEditedBy)` | already converted ✓ |

All FK dependencies resolved.
