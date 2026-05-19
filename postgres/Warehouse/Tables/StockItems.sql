CREATE SCHEMA IF NOT EXISTS warehouse;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.stock_item_id_seq START 228 INCREMENT 1;

CREATE TABLE warehouse.stockitems (
    StockItemID            INTEGER         DEFAULT nextval('sequences.stock_item_id_seq') NOT NULL,
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
    Tags                   TEXT            GENERATED ALWAYS AS (CustomFields::jsonb->>'Tags') STORED,
    SearchDetails          TEXT            GENERATED ALWAYS AS (StockItemName || ' ' || COALESCE(MarketingComments, '')) STORED,
    LastEditedBy           INTEGER         NOT NULL,
    ValidFrom              TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                TIMESTAMP(6)    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Warehouse_StockItems PRIMARY KEY (StockItemID),
    CONSTRAINT FK_Warehouse_StockItems_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Warehouse_StockItems_ColorID_Warehouse_Colors FOREIGN KEY (ColorID) REFERENCES warehouse.colors (ColorID),
    CONSTRAINT FK_Warehouse_StockItems_OuterPackageID_Warehouse_PackageTypes FOREIGN KEY (OuterPackageID) REFERENCES warehouse.packagetypes (PackageTypeID),
    CONSTRAINT FK_Warehouse_StockItems_SupplierID_Purchasing_Suppliers FOREIGN KEY (SupplierID) REFERENCES purchasing.suppliers (SupplierID),
    CONSTRAINT FK_Warehouse_StockItems_UnitPackageID_Warehouse_PackageTypes FOREIGN KEY (UnitPackageID) REFERENCES warehouse.packagetypes (PackageTypeID),
    CONSTRAINT UQ_Warehouse_StockItems_StockItemName UNIQUE (StockItemName)
);

CREATE INDEX FK_Warehouse_StockItems_SupplierID ON warehouse.stockitems (SupplierID ASC);
CREATE INDEX FK_Warehouse_StockItems_ColorID ON warehouse.stockitems (ColorID ASC);
CREATE INDEX FK_Warehouse_StockItems_UnitPackageID ON warehouse.stockitems (UnitPackageID ASC);
CREATE INDEX FK_Warehouse_StockItems_OuterPackageID ON warehouse.stockitems (OuterPackageID ASC);

COMMENT ON TABLE warehouse.stockitems IS 'Main entity table for stock items';
COMMENT ON COLUMN warehouse.stockitems.StockItemID IS 'Numeric ID used for reference to a stock item within the database';
COMMENT ON COLUMN warehouse.stockitems.StockItemName IS 'Full name of a stock item (but not a full description)';
COMMENT ON COLUMN warehouse.stockitems.SupplierID IS 'Usual supplier for this stock item';
COMMENT ON COLUMN warehouse.stockitems.ColorID IS 'Color (optional) for this stock item';
COMMENT ON COLUMN warehouse.stockitems.UnitPackageID IS 'Usual package for selling units of this stock item';
COMMENT ON COLUMN warehouse.stockitems.OuterPackageID IS 'Usual package for selling outers of this stock item (ie cartons, boxes, etc.)';
COMMENT ON COLUMN warehouse.stockitems.Brand IS 'Brand for the stock item (if the item is branded)';
COMMENT ON COLUMN warehouse.stockitems.Size IS 'Size of this item (eg: 100mm)';
COMMENT ON COLUMN warehouse.stockitems.LeadTimeDays IS 'Number of days typically taken from order to receipt of this stock item';
COMMENT ON COLUMN warehouse.stockitems.QuantityPerOuter IS 'Quantity of the stock item in an outer package';
COMMENT ON COLUMN warehouse.stockitems.IsChillerStock IS 'Does this stock item need to be in a chiller?';
COMMENT ON COLUMN warehouse.stockitems.Barcode IS 'Barcode for this stock item';
COMMENT ON COLUMN warehouse.stockitems.TaxRate IS 'Tax rate to be applied';
COMMENT ON COLUMN warehouse.stockitems.UnitPrice IS 'Selling price (ex-tax) for one unit of this product';
COMMENT ON COLUMN warehouse.stockitems.RecommendedRetailPrice IS 'Recommended retail price for this stock item';
COMMENT ON COLUMN warehouse.stockitems.TypicalWeightPerUnit IS 'Typical weight for one unit of this product (packaged)';
COMMENT ON COLUMN warehouse.stockitems.MarketingComments IS 'Marketing comments for this stock item (shared outside the organization)';
COMMENT ON COLUMN warehouse.stockitems.InternalComments IS 'Internal comments (not exposed outside organization)';
COMMENT ON COLUMN warehouse.stockitems.Photo IS 'Photo of the product';
COMMENT ON COLUMN warehouse.stockitems.CustomFields IS 'Custom fields added by system users';
COMMENT ON COLUMN warehouse.stockitems.Tags IS 'Advertising tags associated with this stock item (JSON array retrieved from CustomFields)';
COMMENT ON COLUMN warehouse.stockitems.SearchDetails IS 'Combination of columns used by full text search';
