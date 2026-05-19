# Conversion summary: WebApi.UpdateSpecialDealFromJson

## Source
- **SP file:** `wwi-ssdt/wwi-ssdt/WebApi/Stored Procedures/UpdateSpecialDealFromJson.sql`
- **Pattern:** Update from JSON (partial update)
- **Output:** `postgres/WebApi/Functions/update_special_deal_from_json.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION webapi.update_special_deal_from_json(p_special_deal text, p_special_deal_id integer, p_user_id integer) RETURNS void
```

## Conversion notes
- Direct assignment (allow NULL) for: StockItemID, CustomerID, BuyingGroupID, CustomerCategoryID, StockGroupID, DiscountAmount, DiscountPercentage, UnitPrice — all nullable FK/value fields
- `COALESCE` for: DealDescription, StartDate, EndDate

## TODOs
None.

## Tables referenced
| Table | Postgres file |
|---|---|
| `sales.specialdeals` | `postgres/Sales/Tables/SpecialDeals.sql` |
