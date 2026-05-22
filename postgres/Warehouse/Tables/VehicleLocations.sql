CREATE SCHEMA IF NOT EXISTS warehouse;

-- New table: no MSSQL source equivalent.
-- Replaces OnDisk.VehicleLocations / InMemory.VehicleLocations (SQL Server In-Memory OLTP demo tables)
-- which have no PostgreSQL counterpart. Required by the migrated vehicle-location-insert workload driver.

CREATE TABLE IF NOT EXISTS warehouse.vehiclelocations
(
    VehicleLocationID  BIGINT          GENERATED ALWAYS AS IDENTITY NOT NULL,
    RegistrationNumber VARCHAR(20)     NOT NULL,
    TrackedWhen        TIMESTAMPTZ     NOT NULL,
    Longitude          NUMERIC(18, 4)  NOT NULL,
    Latitude           NUMERIC(18, 4)  NOT NULL,
    CONSTRAINT PK_Warehouse_VehicleLocations PRIMARY KEY (VehicleLocationID)
);
