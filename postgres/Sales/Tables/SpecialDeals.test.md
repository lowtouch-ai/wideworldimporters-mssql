# pgtable-test report: Sales.SpecialDeals

## Source
- **Table file:** `postgres/Sales/Tables/SpecialDeals.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `sales.buyinggroups` | ✓ Applied (FK stripped) | `postgres/Sales/Tables/BuyingGroups.sql` |
| `sales.customercategories` | ✓ Applied (FK stripped) | `postgres/Sales/Tables/CustomerCategories.sql` |
| `sales.customers` | ✓ Applied (FK stripped) | `postgres/Sales/Tables/Customers.sql` |
| `warehouse.stockgroups` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockGroups.sql` |
| `warehouse.stockitems` | ✓ Applied (FK stripped) | `postgres/Warehouse/Tables/StockItems.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.special_deal_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success (NOTICE: 2 constraint names truncated to 63 chars — PostgreSQL limit, not an error)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 14

## Column inventory
| Column | Type |
|---|---|
| `SpecialDealID` | integer |
| `StockItemID` | integer |
| `CustomerID` | integer |
| `BuyingGroupID` | integer |
| `CustomerCategoryID` | integer |
| `StockGroupID` | integer |
| `DealDescription` | character varying |
| `StartDate` | date |
| `EndDate` | date |
| `DiscountAmount` | numeric |
| `DiscountPercentage` | numeric |
| `UnitPrice` | numeric |
| `LastEditedBy` | integer |
| `LastEditedWhen` | timestamp without time zone |

## Next steps
- Session 3 complete. Continue with Session 4: `/pgtable-test postgres/Sales/Tables/Orders.sql`
