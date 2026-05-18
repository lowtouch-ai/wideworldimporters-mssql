# pgtable-test report: Application.People_Archive

## Source
- **Table file:** `postgres/Application/Tables/People_Archive.sql`
- **Test run:** 2026-05-18

## Dependencies
None (archive table)

## Result
- Table load: ✓ Success
- Columns verified: 21

## Column inventory
| Column | Type |
|---|---|
| `personid` | integer |
| `fullname` | character varying |
| `preferredname` | character varying |
| `searchname` | character varying |
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
