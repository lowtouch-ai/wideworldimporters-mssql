# pgtable-test report: Application.Countries

## Source
- **Table file:** `postgres/Application/Tables/Countries.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.country_id_seq` | ✓ Created (START 242) |

## Extensions
| Extension | Status |
|---|---|
| `pgcrypto` | ✓ Installed |
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 14

## Column inventory
| Column | Type (in test) |
|---|---|
| `countryid` | integer |
| `countryname` | character varying |
| `formalname` | character varying |
| `isoalpha3code` | character varying |
| `isonumericcode` | integer |
| `countrytype` | character varying |
| `latestrecordedpopulation` | bigint |
| `continent` | character varying |
| `region` | character varying |
| `subregion` | character varying |
| `border` | text (⚠ should be `geography` — PostGIS not in container) |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |

## TODOs
- None

## Next steps
- Install PostGIS in `postgres_15.1` container to test geography columns properly
- Continue: `/pgtable-test postgres/Application/Tables/Countries_Archive.sql`
