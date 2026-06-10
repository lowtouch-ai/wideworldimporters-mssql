# pgtable-test report: Application.People

## Source
- **Table file:** `postgres/Application/Tables/People.sql`
- **Test run:** 2026-05-18

## Dependencies
| Dependency | Status | Notes |
|---|---|---|
| `sequences.person_id_seq` | ✓ Created | Self-FK only; no external table deps |

## Result
- Table load: ✓ Success
- SELECT LIMIT 0: ✓ ok
- Columns verified: 21

## Column inventory
| Column | Type |
|---|---|
| `PersonID` | integer |
| `FullName` | character varying |
| `PreferredName` | character varying |
| `SearchName` | character varying (generated stored) |
| `IsPermittedToLogon` | boolean |
| `LogonName` | character varying |
| `IsExternalLogonProvider` | boolean |
| `HashedPassword` | bytea |
| `IsSystemUser` | boolean |
| `IsEmployee` | boolean |
| `IsSalesperson` | boolean |
| `UserPreferences` | text |
| `PhoneNumber` | character varying |
| `FaxNumber` | character varying |
| `EmailAddress` | character varying |
| `Photo` | bytea |
| `CustomFields` | text |
| `OtherLanguages` | text |
| `LastEditedBy` | integer |
| `ValidFrom` | timestamp without time zone |
| `ValidTo` | timestamp without time zone |

## TODOs
- `OtherLanguages` was a non-persisted computed column (`json_query` on `CustomFields`). Now a plain nullable TEXT column — application layer must populate it if needed.

## Next steps
- Continue with: `/pgtable-test postgres/Application/Tables/Countries.sql`
