CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.stockitems_archive (
    StockItemID            INTEGER         NOT NULL,
    StockItemName          VARCHAR(100)    NOT NULL,
    SupplierID             INTEGER         NOT NULL,
    ColorID                INTEGER         NULL,
    UnitPackageID          INTEGER         NOT NULL,
    OuterPackageID         INTEGER         NOT NULL,
    Brand                  VARCHAR(50)     NULL,
    Size                   VARCHAR(20)     NULL,
    LeadTimeDays           INTEGER         NOT NULL,
    QuantityPerOuter       INTEGER         NOT NULL,
    IsChillerStock         BOOLEAN         NOT NULL,
    Barcode                VARCHAR(50)     NULL,
    TaxRate                NUMERIC(18, 3)  NOT NULL,
    UnitPrice              NUMERIC(18, 2)  NOT NULL,
    RecommendedRetailPrice NUMERIC(18, 2)  NULL,
    TypicalWeightPerUnit   NUMERIC(18, 3)  NOT NULL,
    MarketingComments      TEXT            NULL,
    InternalComments       TEXT            NULL,
    Photo                  BYTEA           NULL,
    CustomFields           TEXT            NULL,
    Tags                   TEXT            NULL,
    SearchDetails          TEXT            NOT NULL,
    LastEditedBy           INTEGER         NOT NULL,
    ValidFrom              TIMESTAMP(6)    NOT NULL,
    ValidTo                TIMESTAMP(6)    NOT NULL
);

CREATE INDEX ix_StockItems_Archive ON warehouse.stockitems_archive (ValidTo ASC, ValidFrom ASC);
