# pgtable-test report: Application.StateProvinces

## Source
- **Table file:** `postgres/Application/Tables/StateProvinces.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.countries` | ✓ Applied (FK stripped) | `postgres/Application/Tables/Countries.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.state_province_id_seq` | ✓ Created (START 54) |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 10

## Column inventory
| Column | Type |
|---|---|
| `stateprovinceid` | integer |
| `stateprovincecode` | character varying |
| `stateprovincename` | character varying |
| `countryid` | integer |
| `salesterritory` | character varying |
| `border` | geography ✓ |
| `latestrecordedpopulation` | bigint |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
