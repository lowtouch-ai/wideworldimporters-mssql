# Conversion summary: Orders.sql

## Files converted
- **Source:** `wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql`
- **Output:** `postgres/Sales/Tables/Orders.sql`

## Conversions applied
- `[Sales].[Orders]` → `sales.orders`
- `INT` → `INTEGER`, `NVARCHAR(MAX)` → `TEXT`, `NVARCHAR(20)` → `VARCHAR(20)`, `BIT` → `BOOLEAN`, `DATETIME2(7)` → `TIMESTAMP(6)`, `DATE` → `DATE`
- `NEXT VALUE FOR [Sequences].[OrderID]` → `nextval('sequences.order_id_seq')` + `CREATE SEQUENCE` emitted above the table
- `DEFAULT (sysdatetime())` → `DEFAULT CURRENT_TIMESTAMP`
- `CONSTRAINT [DF_...]` named defaults removed; bare `DEFAULT` kept
- `PRIMARY KEY CLUSTERED` → `PRIMARY KEY`
- `CREATE NONCLUSTERED INDEX` → `CREATE INDEX`
- 4 index-level extended properties → omitted (with comment)
- 1 table-level extended property → `COMMENT ON TABLE`
- 14 column-level extended properties → `COMMENT ON COLUMN`

## Next files to convert (unresolved dependencies)

| Dependency | Required by (columns) | Run |
|---|---|---|
| `application.people` | `sales.orders (LastEditedBy, ContactPersonID, PickedByPersonID, SalespersonPersonID)` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql` |
| `sales.customers` | `sales.orders (CustomerID)` | `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql` |

> Tip: convert a whole schema at once: `/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables`
