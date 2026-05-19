CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.colors AS
SELECT ColorID, ColorName
FROM warehouse.colors;
