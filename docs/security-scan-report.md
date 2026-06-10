# Security Scan Report

**Date:** 2026-06-10
**Branch:** 11449/migration-docker
**Scope:** Full repository scan before client share

---

## Summary

| Category | Count | Status |
|---|---|---|
| Skills files (`.claude/commands/` + `CLAUDE.md`) | 10 files | ✅ Clean — safe to share |
| Critical credential exposures | 3 files | ❌ Must fix before sharing full repo |
| High severity credential exposures | 3 files | ❌ Must fix before sharing full repo |
| Medium severity credential exposures | 9 files | ⚠️ Recommend fixing |
| Low severity | 1 file | ⚠️ Minor hardcoded IP |
| Informational (Microsoft sample passwords) | 5 files | ℹ️ Intentional — do not change |

---

## Skills Files — CLEAN ✓

The 9 `.claude/commands/*.md` files and `CLAUDE.md` contain **no credentials, no internal infrastructure URLs, and no sensitive data**. The three mentions of the word "password" in these files are documentation notes (e.g. "no password needed — local trust auth inside container"). These files are safe to share as-is.

---

## Critical — Real Credentials Exposed

### `wwi-app/appsettings.json`
- `"Password=Sp1d3rman!"` — hardcoded MSSQL WebApi login password
- `"Authority": "https://auth2025.lowtouch.ai/auth/realms/lowtouch.ai"` — internal Keycloak server URL
- `"ClientId": "rfp2025b"` — internal Keycloak client ID

**Fix:** Replace password with `<YOUR_MSSQL_PASSWORD>`, Keycloak Authority with `https://your-keycloak-host/auth/realms/your-realm`, ClientId with `<YOUR_KEYCLOAK_CLIENT_ID>`. Credentials should be supplied via environment variables or .NET User Secrets at runtime.

---

### `wwi-app/appsettings.Testing.json`
- `"Password=postgres"` in PostgreSQL connection string
- `"Host=172.19.0.8"` — internal Docker bridge IP
- Same Keycloak Authority + ClientId as above

**Fix:** Replace password with `<YOUR_PG_PASSWORD>`, host with `localhost`. Supply real values via `POSTGRES_TEST_HOST` env var (the test fixture already supports this override).

---

### `docker-compose.yml` (line ~15)
- `Password=postgres` hardcoded in the `ConnectionStrings__WWI` environment variable

**Fix:** Change to `Password=${PG_PASSWORD:-postgres}`. Docker Compose natively expands `${VAR:-default}` syntax, making this both functional and self-documenting. Add `PG_PASSWORD` to `.env`.

---

## High — Credentials in Documentation

### `docs/DEPLOY.md` (4 occurrences)
- Lines 34, 43, 59, 74: `Sp1d3rman!` appears in deployment commands as `-e MSSQL_SA_PASSWORD=Sp1d3rman!` and `-P "Sp1d3rman!"`

**Fix:**
- `-e MSSQL_SA_PASSWORD=Sp1d3rman!` → `-e MSSQL_SA_PASSWORD="${MSSQL_SA_PASSWORD:?must be set}"`
- `-P "Sp1d3rman!"` → `-P "$MSSQL_SA_PASSWORD"`
- Add prerequisites block at top: `export MSSQL_SA_PASSWORD=<your-strong-password>`

---

### `docs/docker-setup.md` (6 occurrences)
- Six references to `Sp1d3rman!` in code blocks — sqlcmd invocations and one `CREATE LOGIN` SQL statement

**Fix:** Same pattern as `DEPLOY.md`. For the SQL statement: `PASSWORD = 'Sp1d3rman!'` → `PASSWORD = '<WEBAPI_PASSWORD>'` with a comment instructing the reader to set the value.

---

### `wwi-ssdt/wwi-ssdt/Security/Permissions.sql` (line 10)
```sql
CREATE LOGIN WebApi WITH PASSWORD = 'Sp1d3rman!';
```

**Fix:**
```sql
-- Replace <WEBAPI_PASSWORD> with the value from your MSSQL_SA_PASSWORD env var
CREATE LOGIN WebApi WITH PASSWORD = '<WEBAPI_PASSWORD>';
```

---

## Medium — Hardcoded Credentials in Scripts

### `scripts/pgloader-wwi.load`
```
FROM mssql://sa:Sp1d3rman!@172.20.0.3:1433/WideWorldImporters
INTO postgresql://postgres:postgres@172.19.0.5:5432/postgres
```
Credentials and internal Docker bridge IPs hardcoded inline.

**Fix:**
```
FROM mssql://sa:${MSSQL_SA_PASSWORD}@${MSSQL_HOST}:1433/WideWorldImporters
INTO postgresql://postgres:${PG_PASS}@${PG_HOST}:5432/postgres
```
pgloader supports env var interpolation natively.

---

### Python scripts (5 files)
All five share the same pattern:

| File | Issue |
|---|---|
| `scripts/migrate_data.py` | `os.getenv("MSSQL_PASS", "Sp1d3rman!")` + `os.getenv("PG_HOST", "172.19.0.5")` |
| `scripts/validate_migration.py` | Same pattern |
| `scripts/export_to_sql.py` | `os.getenv("MSSQL_PASS", "Sp1d3rman!")` |
| `scripts/test_functions.py` | Same pattern |
| `scripts/test_migration_full.py` | Same pattern |

**Fix:** Change default fallback from the literal password to an empty string:
```python
password=os.getenv("MSSQL_PASS", ""),  # Set MSSQL_PASS env var before running
```
Change internal IP defaults:
```python
os.getenv("PG_HOST", "localhost")
os.getenv("MSSQL_HOST", "localhost")
```

---

### `scripts/run-migration.sh` and `scripts/run-validation.sh`
Both contain `-P "Sp1d3rman!"` in sqlcmd invocations.

**Fix:**
```bash
-P "${MSSQL_SA_PASSWORD:?MSSQL_SA_PASSWORD env var is required}"
```
The `:?` bash expansion causes the script to exit with a clear error if the variable is unset.

---

## Low — Hardcoded Internal IP

### `wwi-app.Tests/Fixtures/DockerPostgresFixture.cs` (line ~16)
Fallback value `"172.19.0.8"` used when `POSTGRES_TEST_HOST` env var is not set.

**Fix:** Change fallback from `"172.19.0.8"` to `"localhost"`. The env var override path is already correct.

---

## Informational — Microsoft Sample Passwords (Do Not Change)

The following files contain `SQLRocks!00`, which is the **publicly documented Microsoft WideWorldImporters demo password**. It appears verbatim in Microsoft's published GitHub source and is used by the sample stored procedures to demonstrate row-level security and data masking. Changing it would break the sample scripts.

| File | Context |
|---|---|
| `sample-scripts/row-level-security/DemonstrateRLS.sql` | Microsoft demo script |
| `sample-scripts/row-level-security/DemonstrateRLS - Window 2.sql` | Microsoft demo script (comment only) |
| `sample-scripts/dynamic-data-masking/DemonstrateDDM.SQL` | Microsoft demo script |
| `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ActivateWebsiteLogons.sql` | Sample SP — uses HASHBYTES, not a real login |
| `wwi-ssdt/wwi-ssdt/DataLoadSimulation/Stored Procedures/ChangePasswords.sql` | Sample SP |

---

## Git History Warning

Replacing credentials in files cleans the working tree, but **git history retains the old values**. Anyone with access to the full repository (including git history) can recover the original passwords with `git log -p`.

**Mitigations:**
- **Share only the skills zip** (`wwi-claude-skills.zip`) — no git history, no exposure.
- **Share the full repo** — run [`git filter-repo`](https://github.com/newren/git-filter-repo) to rewrite history and remove the credential strings before pushing to a client-accessible remote.

---

## Recommended Fix Order

If remediating the full repo:

1. `wwi-app/appsettings.json` — highest visibility, most dangerous
2. `wwi-app/appsettings.Testing.json`
3. `docker-compose.yml`
4. `docs/DEPLOY.md` + `docs/docker-setup.md`
5. `wwi-ssdt/wwi-ssdt/Security/Permissions.sql`
6. `scripts/pgloader-wwi.load`
7. 5× Python scripts
8. 2× shell scripts
9. `wwi-app.Tests/Fixtures/DockerPostgresFixture.cs`
10. Run `git filter-repo` to scrub history, then force-push
