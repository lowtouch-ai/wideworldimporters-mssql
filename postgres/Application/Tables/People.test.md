# pgtable-test report: Application.People

## Source
- **Table file:** `postgres/Application/Tables/People.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `application.people` | ✓ Self-reference — applied as dep for Countries.sql, FK stripped |

## Sequences
| Sequence | Status |
|---|---|
| `sequences.person_id_seq` | ✓ Created (START 3310) |

## Result
- Table load: ✓ Success (applied as dependency before Countries)
- SELECT LIMIT 0: ✓ ok
- Columns verified: 21

## Column inventory
| Column | Type |
|---|---|
| `personid` | integer |
| `fullname` | character varying |
| `preferredname` | character varying |
| `searchname` | text (GENERATED ALWAYS AS … STORED) |
| `ispermittedtologon` | boolean |
| `logonname` | character varying |
| `isexternallogonprovider` | boolean |
| `hashedpassword` | bytea |
| `issystemuser` | boolean |
| `isemployee` | boolean |
| `issalesperson` | boolean |
| `userpreferences` | text |
| `phonenumber` | character varying |
| `faxnumber` | character varying |
| `emailaddress` | character varying |
| `photo` | bytea |
| `customfields` | text |
| `otherlanguages` | text |
| `lasteditedby` | integer |
| `validfrom` | timestamp without time zone |
| `validto` | timestamp without time zone |

## TODOs
- `OtherLanguages` is a plain TEXT column; was a non-persisted computed column (`json_query` on `CustomFields`) in MSSQL — application layer must populate it.
