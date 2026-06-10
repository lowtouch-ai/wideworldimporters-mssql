CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: MSSQL TABLE TYPE converted to PostgreSQL composite type.
-- TVP parameters that used this type should be passed as JSONB arrays in PostgreSQL.
CREATE TYPE website.sensor_data_list AS (
    SensorDataListID     INTEGER,
    ColdRoomSensorNumber INTEGER,
    RecordedWhen         TIMESTAMP(6),
    Temperature          NUMERIC(18, 2)
);
