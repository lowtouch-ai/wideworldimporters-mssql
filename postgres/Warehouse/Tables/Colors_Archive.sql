CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.colors_archive (
    ColorID      INTEGER      NOT NULL,
    ColorName    VARCHAR(20)  NOT NULL,
    LastEditedBy INTEGER      NOT NULL,
    ValidFrom    TIMESTAMP(6) NOT NULL,
    ValidTo      TIMESTAMP(6) NOT NULL
);

CREATE INDEX ix_Colors_Archive ON warehouse.colors_archive (ValidTo ASC, ValidFrom ASC);
