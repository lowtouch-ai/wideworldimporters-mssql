# pgtable-test report: Application.Cities

## Source
- **Table file:** `postgres/Application/Tables/Cities.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.state_provinces` | ✓ Applied (FK stripped) | `postgres/Application/Tables/StateProvinces.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.city_id_seq` | ✓ Created (START 38187) |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 8

## Column inventory
| Column | Type |
|---|---|
| `cityid` | integer |
| `cityname` | character varying |
| `stateprovinceid` | integer |
| `location` | geography ✓ |
| `latestrecordedpopulation` | bigint |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |
