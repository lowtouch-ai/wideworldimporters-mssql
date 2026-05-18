# pgtable-test report: Sales.Customers

## Source
- **Table file:** `postgres/Sales/Tables/Customers.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.cities` | ✓ Applied (FK stripped) | `postgres/Application/Tables/Cities.sql` |
| `application.deliverymethods` | ✓ Applied (FK stripped) | `postgres/Application/Tables/DeliveryMethods.sql` |
| `sales.buyinggroups` | ✓ Applied (FK stripped) | `postgres/Sales/Tables/BuyingGroups.sql` |
| `sales.customercategories` | ✓ Applied (FK stripped) | `postgres/Sales/Tables/CustomerCategories.sql` |
| `sales.customers` | Self-referential FK — stripped |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.customer_id_seq` | ✓ Created |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Already installed |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 31

## TODOs
- `ValidFrom`/`ValidTo`: were temporal system-time columns; converted to plain timestamps
- `DeliveryLocation`: PostGIS geography column — requires PostGIS extension

## Next steps
- Continue with: `/pgtable-test postgres/Sales/Tables/Customers_Archive.sql`
