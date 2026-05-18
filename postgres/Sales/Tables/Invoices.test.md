# pgtable-test report: Sales.Invoices

## Source
- **Table file:** `postgres/Sales/Tables/Invoices.sql`
- **Test run:** 2026-05-18T19:20:22Z

## Dependencies
| Dependency | Status |
|---|---|
| `application.people` | ✓ Applied (pre-existing from Session 1) |
| `application.deliverymethods` | ✓ Applied (pre-existing from Session 1) |
| `sales.customers` | ✓ Applied (pre-existing from Session 3) |
| `sales.orders` | ✓ Applied (converted this session) |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.invoice_id_seq` | ✓ Created (pre-existing from Session 1) |

## Result
- Table load: ✓ Success (FK constraints stripped for test isolation)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 24

## TODOs
- `ConfirmedDeliveryTime` and `ConfirmedReceivedBy` are regular nullable columns (were non-persisted computed in MSSQL); populate via trigger or application logic if needed.
- CHECK constraint on `ReturnedDeliveryData` uses `::jsonb` cast (raises exception on invalid JSON, rather than constraint violation — same net effect).
