# Conversion summary: Website.CalculateCustomerPrice

## Source
- **Function file:** `wwi-ssdt/wwi-ssdt/Website/Functions/CalculateCustomerPrice.sql`
- **Pattern:** Scalar function with pricing logic → `RETURNS numeric(18, 2)`
- **Output:** `postgres/Website/Functions/calculate_customer_price.sql`

## Function signature
```sql
CREATE OR REPLACE FUNCTION website.calculate_customer_price(p_customer_id integer, p_stock_item_id integer, p_pricing_date date) RETURNS numeric(18, 2)
```

## Parameter mapping
| MSSQL Parameter | PG Parameter | Type |
|---|---|---|
| `@CustomerID int` | `p_customer_id integer` | `integer` |
| `@StockItemID int` | `p_stock_item_id integer` | `integer` |
| `@PricingDate date` | `p_pricing_date date` | `date` |

## Conversion notes
- `WITH EXECUTE AS OWNER` → removed
- `DECLARE @Var type` → `_var type` in DECLARE block (underscore prefix for local variables)
- `SET @var = expr` → `_var := expr`
- `SELECT @var = col FROM ...` → `SELECT col INTO _var FROM ...`
- `IF condition BEGIN ... END` → `IF condition THEN ... END IF;`
- `decimal(18,2)` / `decimal(18,3)` → `numeric(18,2)` / `numeric(18,3)`
- `ROUND(x, 2)` → `ROUND(x, 2)` (unchanged)
- All three SpecialDeals subqueries (UnitPrice, DiscountAmount, DiscountPercentage) converted with `OR ... IS NULL` patterns preserved
- `@PricingDate BETWEEN sd.StartDate AND sd.EndDate` → `p_pricing_date BETWEEN sd."StartDate" AND sd."EndDate"` (unchanged, BETWEEN is inclusive in both MSSQL and PostgreSQL)

## TODOs
None.

## Tables referenced
| Table | PostgreSQL file |
|---|---|
| `sales.customers` | `postgres/Sales/Tables/Customers.sql` |
| `warehouse.stockitems` | `postgres/Warehouse/Tables/StockItems.sql` |
| `sales.specialdeals` | `postgres/Sales/Tables/SpecialDeals.sql` |
| `warehouse.stockitemstockgroups` | `postgres/Warehouse/Tables/StockItemStockGroups.sql` |
