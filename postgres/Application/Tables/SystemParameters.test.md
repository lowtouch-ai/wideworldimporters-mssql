# pgtable-test report: Application.SystemParameters

## Source
- **Table file:** `postgres/Application/Tables/SystemParameters.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Applied (FK stripped) | `postgres/Application/Tables/People.sql` |
| `application.cities` | ✓ Applied (FK stripped) | `postgres/Application/Tables/Cities.sql` |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.system_parameter_id_seq` | ✓ Created (START 3) |

## Extensions
| Extension | Status |
|---|---|
| `postgis` | ✓ Installed (postgresql-15-postgis-3) |

## Result
- Table load: ✓ Success
- Columns verified: 13

## Column inventory
| Column | Type |
|---|---|
| `systemparameterid` | integer |
| `deliveryaddressline1` | character varying |
| `deliveryaddressline2` | character varying |
| `deliverycityid` | integer |
| `deliverypostalcode` | character varying |
| `deliverylocation` | geography ✓ |
| `postaladdressline1` | character varying |
| `postaladdressline2` | character varying |
| `postalcityid` | integer |
| `postalpostalcode` | character varying |
| `applicationsettings` | text |
| `lasteditedby` | integer |
| `lasteditedwhen` | timestamp without time zone |
