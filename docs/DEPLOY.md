# Deployment Guide — WideWorldImporters (MSSQL → PostgreSQL)

This guide walks through standing up the MSSQL source container, restoring the
WideWorldImporters database, and migrating the full schema and data into
PostgreSQL.

---

## Prerequisites

- Docker installed and running
- Both containers must be on the same Docker network (`appz-images_agentomatic_net`)
- Python 3 not required locally — the migration runs inside a temporary container

---

## Step 1: Create the shared Docker network

```bash
docker network create appz-images_agentomatic_net
```

If it already exists, Docker will return an error — that's fine, skip it.

---

## Step 2: Start the MSSQL container

```bash
docker run -d \
  --name mssql_wwi \
  --network appz-images_agentomatic_net \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=Sp1d3rman! \
  -e MSSQL_PID=Developer \
  mcr.microsoft.com/mssql/server:2022-latest
```

Wait ~30 seconds for SQL Server to be ready, then verify:

```bash
docker exec mssql_wwi /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -C -Q "SELECT @@VERSION"
```

---

## Step 3: Restore the WideWorldImporters backup

Download the official backup (~122 MB) and restore it into the container:

```bash
curl -L -o /tmp/WideWorldImporters-Full.bak \
  "https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak"

docker cp /tmp/WideWorldImporters-Full.bak mssql_wwi:/tmp/

docker exec mssql_wwi /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -C -Q "
RESTORE DATABASE WideWorldImporters
FROM DISK='/tmp/WideWorldImporters-Full.bak'
WITH
  MOVE 'WWI_Primary'         TO '/var/opt/mssql/data/WideWorldImporters.mdf',
  MOVE 'WWI_UserData'        TO '/var/opt/mssql/data/WideWorldImporters_UserData.ndf',
  MOVE 'WWI_Log'             TO '/var/opt/mssql/data/WideWorldImporters.ldf',
  MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/WideWorldImporters_InMemory_Data_1',
  REPLACE"
```

Confirm the database is present:

```bash
docker exec mssql_wwi /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "Sp1d3rman!" -C -Q "SELECT name FROM sys.databases"
```

`WideWorldImporters` should appear in the list.

---

## Step 4: Start the PostgreSQL container

If `postgres_15.1` is not already running:

```bash
docker run -d \
  --name postgres_15.1 \
  --network appz-images_agentomatic_net \
  -e POSTGRES_PASSWORD=postgres \
  -p 5432:5432 \
  postgis/postgis:15-3.3
```

> The `postgis/postgis` image is required — it includes the PostGIS extension
> used for geography columns. Plain `postgres:15` will not work.

Verify it is healthy:

```bash
docker exec postgres_15.1 psql -U postgres -c "SELECT version();"
```

---

## Step 5: Create the target database

```bash
docker exec postgres_15.1 psql -U postgres -c "CREATE DATABASE wideworldimporters;"
```

---

## Step 6: Apply the PostgreSQL schema

Run from the repo root:

```bash
bash scripts/apply-schema.sh --no-seed
```

This creates all schemas, sequences, tables, types, views, functions, and
applies the fix scripts. The `--no-seed` flag skips the lightweight seed data
since we will load the full MSSQL dataset in the next step.

---

## Step 7: Migrate data from MSSQL

```bash
bash scripts/run-migration.sh
```

This launches a temporary Python container that connects to both databases,
truncates all PostgreSQL tables, streams rows from MSSQL in FK dependency
order, and resets sequences to match the migrated data.

Expected output ends with:

```
Done. 1,057,452 total rows migrated.
=== Migration complete ===
```

---

## Connection details

| | Value |
|---|---|
| **Host** | `localhost` |
| **Port** | `5432` (or the mapped port shown by `docker ps`) |
| **Database** | `wideworldimporters` |
| **User** | `postgres` |
| **Password** | `postgres` |

---

## Subsequent runs

If the containers already exist but are stopped:

```bash
docker start mssql_wwi postgres_15.1
```

To re-migrate data (e.g. after refreshing the MSSQL backup), re-run
Step 7 — the script truncates before inserting so it is safe to re-run.

To fully reset the PostgreSQL database and start over from Step 5:

```bash
docker exec postgres_15.1 psql -U postgres -c "DROP DATABASE wideworldimporters;"
docker exec postgres_15.1 psql -U postgres -c "CREATE DATABASE wideworldimporters;"
bash scripts/apply-schema.sh --no-seed
bash scripts/run-migration.sh
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `sqlcmd: command not found` | Use `/opt/mssql-tools18/bin/sqlcmd` — the tools path changed in SQL Server 2022 images |
| `mssql_wwi container not running` | Run `docker start mssql_wwi` |
| `postgres_15.1 not found on appz-images_agentomatic_net` | Recreate the container with `--network appz-images_agentomatic_net` |
| `ERROR: geography column` | The PG image must be `postgis/postgis`, not plain `postgres` |
| Migration errors on FK violation | The script disables FK checks for the session — if you see FK errors, check that MSSQL data is consistent |
| Port `5432` already in use | Change `-p 5432:5432` to `-p 5433:5432` and update `PG_PORT` env var when running migrations |
