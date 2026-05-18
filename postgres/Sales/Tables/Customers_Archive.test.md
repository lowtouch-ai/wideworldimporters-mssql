# pgtable-test report: Sales.Customers_Archive

## Source
- **Table file:** `postgres/Sales/Tables/Customers_Archive.sql`
- **Test run:** 2026-05-19

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| None | — | Archive table; no foreign keys |

## Sequences
| Sequence | Status |
|---|---|
| None | — |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Already installed |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 31

## Next steps
- Continue with: `/pgtable-test postgres/Purchasing/Tables/PurchaseOrders.sql`
