CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: MSSQL TABLE TYPE converted to PostgreSQL composite type.
-- TVP parameters that used this type should be passed as JSONB arrays in PostgreSQL.
CREATE TYPE website.order_id_list AS (
    OrderID INTEGER
);
