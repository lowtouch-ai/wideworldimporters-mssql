CREATE SCHEMA IF NOT EXISTS website;

-- NOTE: MSSQL TABLE TYPE converted to PostgreSQL composite type.
-- TVP parameters that used this type should be passed as JSONB arrays in PostgreSQL.
CREATE TYPE website.order_list AS (
    OrderReference              INTEGER,
    CustomerID                  INTEGER,
    ContactPersonID             INTEGER,
    ExpectedDeliveryDate        DATE,
    CustomerPurchaseOrderNumber VARCHAR(20),
    IsUndersupplyBackordered    BOOLEAN,
    Comments                    TEXT,
    DeliveryInstructions        TEXT
);
