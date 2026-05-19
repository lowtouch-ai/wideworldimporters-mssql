# Conversion summary: WebApi.DeleteCustomer

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/DeleteCustomer.sql`
- **Pattern:** Simple DML (DELETE by primary key)
- **Output:** `postgres/WebApi/Functions/delete_customer.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.delete_customer(p_customer_id integer) RETURNS void
```

## Parameter mapping
| SP Parameter | PG Parameter | Type | Notes |
|---|---|---|---|
| `@CustomerID int` | `p_customer_id integer` | integer | PK to delete |

## Conversion notes
- `[WebApi].[DeleteCustomer]` → `webapi.delete_customer`
- `WITH EXECUTE AS OWNER` removed
- Parameter prefix `@` → `p_`
- Table schema lowercased and mapped to converted postgres table

## TODOs
None.
