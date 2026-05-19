# pgtable-test report: Warehouse.StockItemTransactions

## Source
- **Table file:** `postgres/Warehouse/Tables/StockItemTransactions.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
| Dependency | Status |
|---|---|
| `application.people` | ✓ Applied (pre-existing from Session 1) |
| `application.transactiontypes` | ✓ Applied (pre-existing from Session 1) |
| `sales.customers` | ✓ Applied (pre-existing from Session 3) |
| `sales.invoices` | ✓ Applied (converted this session) |
| `warehouse.stockitems` | ✓ Applied (pre-existing from Session 3) |
| `purchasing.purchaseorders` | ✓ Applied (pre-existing from Session 3) |
| `purchasing.suppliers` | ✓ Applied (pre-existing from Session 2) |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.transaction_id_seq` | ✓ Created (pre-existing from Session 1) |

## Result
- Table load: ✓ Success (FK constraints stripped for test isolation)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 11

## TODOs
- CLUSTERED COLUMNSTORE index omitted — no PostgreSQL equivalent.
