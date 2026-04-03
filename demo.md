# WideWorldImporters — Migration Pipeline Demo

This walkthrough demonstrates the full MSSQL → PostgreSQL migration pipeline:
convert table DDL, convert a stored procedure to a PL/pgSQL function, seed data,
and execute the function live in a PostgreSQL 15 container.

## Prerequisites

- `postgres_15.1` Docker container running (started via `docker-compose.agentomatic.yml`)
- Claude Code CLI active in this repo

---

## Step 1 — Convert table DDL (dependency chain for Sales.Orders)

`Sales.Orders` has foreign keys to `Application.People` and `Sales.Customers`.
Convert in dependency order so FK references resolve:

```
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Application/Tables/People.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Customers.sql
/mssql-to-postgres wwi-ssdt/wwi-ssdt/Sales/Tables/Orders.sql
```

**Output files produced:**
- `postgres/Application/Tables/People.sql` + `People.md`
- `postgres/Sales/Tables/Customers.sql` + `Customers.md`
- `postgres/Sales/Tables/Orders.sql` + `Orders.md`

---

## Step 2 — Convert stored procedure to PL/pgSQL function

`WebApi.UpdateSalesOrderFromJson` updates a sales order from a JSON payload.
It demonstrates the OPENJSON → `jsonb_to_recordset` conversion pattern.

```
/mssql-to-pgfunc "wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSalesOrderFromJson.sql"
```

**Output files produced:**
- `postgres/WebApi/Functions/update_sales_order_from_json.sql`
- `postgres/WebApi/Functions/update_sales_order_from_json.md`

**Key conversions shown:**
| T-SQL | PL/pgSQL |
|---|---|
| `CREATE PROCEDURE [WebApi].[UpdateSalesOrderFromJson]` | `CREATE OR REPLACE FUNCTION webapi.update_sales_order_from_json(...)` |
| `@SalesOrderID int` | `p_sales_order_id integer` |
| `OPENJSON(@SalesOrder) WITH (col nvarchar(50))` | `jsonb_to_recordset(p_sales_order::jsonb) AS x(col varchar(50))` |
| `UPDATE ... SET col = ISNULL(json.col, existing.col)` | `UPDATE ... SET col = COALESCE(x.col, existing.col)` |
| `@@ROWCOUNT = 0` → error | `GET DIAGNOSTICS _rowcount = ROW_COUNT; IF _rowcount = 0 THEN RAISE ...` |
| `WITH EXECUTE AS OWNER` | removed |
| `SET NOCOUNT ON` | removed |

---

## Step 3 — Load function into Postgres 15 and smoke-test

This command connects to `postgres_15.1`, creates the `wwi_test` schema, applies
the converted table DDL (or stubs), seeds minimal rows, loads the function, and
runs a test call.

```
/pgfunc-test postgres/WebApi/Functions/update_sales_order_from_json.sql
```

**What happens inside the container:**
1. Schema created: `CREATE SCHEMA IF NOT EXISTS wwi_test;`
2. Table DDL applied from `postgres/Application/Tables/People.sql`, `postgres/Sales/Tables/Customers.sql`, `postgres/Sales/Tables/Orders.sql`
3. Seed data inserted (idempotent — safe to re-run):
   ```sql
   INSERT INTO application.people (PersonID, ...) VALUES (1, 'Demo User', ...) ON CONFLICT DO NOTHING;
   INSERT INTO sales.customers (CustomerID, ...) VALUES (1, 'Demo Customer', ...) ON CONFLICT DO NOTHING;
   INSERT INTO sales.orders (OrderID, CustomerID, ...) VALUES (1, 1, ...) ON CONFLICT DO NOTHING;
   ```
4. Function loaded: `webapi.update_sales_order_from_json(...)`
5. Test call executed:
   ```sql
   SELECT webapi.update_sales_order_from_json(1, '{"SalespersonPersonID": 1}'::text);
   ```
6. Post-call state shown:
   ```sql
   SELECT * FROM sales.orders WHERE "OrderID" = 1;
   ```

---

## Reset between runs

To wipe the test schema and start clean:

```bash
docker exec postgres_15.1 psql -U postgres -d postgres \
  -c "DROP SCHEMA wwi_test CASCADE; CREATE SCHEMA wwi_test;"
```

---

## Full pipeline summary

```
MSSQL DDL (.sql)
    │
    ▼  /mssql-to-postgres
PostgreSQL table DDL  →  postgres/<Schema>/Tables/<Table>.sql
    │
    ▼  /mssql-to-pgfunc
PL/pgSQL function     →  postgres/<Schema>/Functions/<function>.sql
    │
    ▼  /pgfunc-test
postgres_15.1 container (wwi_test schema)
    ├── Tables applied
    ├── Seed data inserted
    ├── Function loaded
    └── Smoke test executed  ✓
```
