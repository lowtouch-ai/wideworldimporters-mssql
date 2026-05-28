# pgtable-test report: Sales.BuyingGroups

## Source
- **Table file:** `postgres/Sales/Tables/BuyingGroups.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.buying_group_id_seq` | ✓ Created |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 5

## Column inventory
| Column | Type |
|---|---|
| `BuyingGroupID` | integer |
| `BuyingGroupName` | character varying |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |

## Next steps
- Continue: `/pgtable-test postgres/Sales/Tables/BuyingGroups_Archive.sql`
