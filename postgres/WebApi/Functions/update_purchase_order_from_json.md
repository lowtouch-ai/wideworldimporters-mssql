# Conversion summary: WebApi.UpdatePurchaseOrderFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdatePurchaseOrderFromJson.sql`
- **Pattern:** Update from JSON (partial update)
- **Output:** `postgres/WebApi/Functions/update_purchase_order_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_purchase_order_from_json(p_purchase_order text, p_purchase_order_id integer, p_user_id integer) RETURNS void
```

## Conversion notes
- `COALESCE` for: SupplierID, OrderDate, DeliveryMethodID, ContactPersonID, IsOrderFinalized
- Direct for: ExpectedDeliveryDate, SupplierReference (nullable — can be cleared)
- `IsOrderFinalized` is a regular boolean column in PostgreSQL (not generated)

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `purchasing.purchaseorders` | `postgres/Purchasing/Tables/PurchaseOrders.sql` |
