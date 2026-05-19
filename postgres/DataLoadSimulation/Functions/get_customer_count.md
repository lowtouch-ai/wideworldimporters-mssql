# Conversion summary: DataLoadSimulation.GetCustomerCount

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Functions/GetCustomerCount.sql`
- **Pattern:** Scalar function → `RETURNS integer`
- **Output:** `postgres/DataLoadSimulation/Functions/get_customer_count.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION dataloadsimulation.get_customer_count(p_customer_name varchar(50)) RETURNS integer
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@CustomerName NVARCHAR(50)` | `p_customer_name varchar(50)` | `varchar(50)` |

## Conversion notes
- `SELECT @CustCount = COUNT(*) FROM [Sales].[Customers] WHERE [CustomerName] = @CustomerName` → `SELECT COUNT(*) INTO _cust_count FROM sales.customers WHERE "CustomerName" = p_customer_name`
- `NVARCHAR(50)` → `varchar(50)`
- `RETURNS INT` → `RETURNS integer`

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
