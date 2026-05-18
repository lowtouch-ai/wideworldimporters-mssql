CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE SEQUENCE IF NOT EXISTS sequences.color_id_seq START 1 INCREMENT 1;

CREATE TABLE warehouse.colors (
    ColorID      INTEGER      DEFAULT nextval('sequences.color_id_seq') NOT NULL,
    ColorName    VARCHAR(20)  NOT NULL,
    LastEditedBy INTEGER      NOT NULL,
    ValidFrom    TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo      TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_Colors PRIMARY KEY (ColorID),
    CONSTRAINT FK_Warehouse_Colors_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Warehouse_Colors_ColorName UNIQUE (ColorName)
);

COMMENT ON TABLE warehouse.colors IS 'Stock items can (optionally) have colors';
COMMENT ON COLUMN warehouse.colors.ColorID IS 'Numeric ID used for reference to a color within the database';
COMMENT ON COLUMN warehouse.colors.ColorName IS 'Full name of a color that can be used to describe stock items';
