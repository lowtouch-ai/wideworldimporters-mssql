# Conversion summary: WebApi.UpdateSalesOrderFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSalesOrderFromJson.sql`
- **Pattern:** Update from JSON (partial update)
- **Output:** `postgres/WebApi/Functions/update_sales_order_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_sales_order_from_json(p_sales_order text, p_sales_order_id integer, p_user_id integer) RETURNS void
```

## Conversion notes
- All fields use `COALESCE` (all ISNULL in source)
- `@SalesOrderID` parameter name maps to `orders.orderid` (SP uses order alias)
- `PickingCompletedWhen` typed as `date` (source is `date` in WITH clause)

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.orders` | `postgres/Sales/Tables/Orders.sql` |
