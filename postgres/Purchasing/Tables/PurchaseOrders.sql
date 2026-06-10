CREATE SCHEMA IF NOT EXISTS purchasing;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.purchase_order_id_seq START 4427 INCREMENT 1;

CREATE TABLE purchasing.purchaseorders (
    PurchaseOrderID      INTEGER        DEFAULT nextval('sequences.purchase_order_id_seq') NOT NULL,
    SupplierID           INTEGER        NOT NULL,
    OrderDate            DATE           NOT NULL,
    DeliveryMethodID     INTEGER        NOT NULL,
    ContactPersonID      INTEGER        NOT NULL,
    ExpectedDeliveryDate DATE           NULL,
    SupplierReference    VARCHAR(20)    NULL,
    IsOrderFinalized     BOOLEAN        NOT NULL,
    Comments             TEXT           NULL,
    InternalComments     TEXT           NULL,
    LastEditedBy         INTEGER        NOT NULL,
    LastEditedWhen       TIMESTAMP(6)   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Purchasing_PurchaseOrders PRIMARY KEY (PurchaseOrderID),
    CONSTRAINT FK_Purchasing_PurchaseOrders_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_PurchaseOrders_ContactPersonID_Application_People FOREIGN KEY (ContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Purchasing_PurchaseOrders_DeliveryMethodID_Application_DeliveryMethods FOREIGN KEY (DeliveryMethodID) REFERENCES application.deliverymethods (DeliveryMethodID),
    CONSTRAINT FK_Purchasing_PurchaseOrders_SupplierID_Purchasing_Suppliers FOREIGN KEY (SupplierID) REFERENCES purchasing.suppliers (SupplierID)
);

CREATE INDEX FK_Purchasing_PurchaseOrders_SupplierID ON purchasing.purchaseorders (SupplierID ASC);
CREATE INDEX FK_Purchasing_PurchaseOrders_DeliveryMethodID ON purchasing.purchaseorders (DeliveryMethodID ASC);
CREATE INDEX FK_Purchasing_PurchaseOrders_ContactPersonID ON purchasing.purchaseorders (ContactPersonID ASC);

COMMENT ON TABLE purchasing.purchaseorders IS 'Details of supplier purchase orders';
COMMENT ON COLUMN purchasing.purchaseorders.PurchaseOrderID IS 'Numeric ID used for reference to a purchase order within the database';
COMMENT ON COLUMN purchasing.purchaseorders.SupplierID IS 'Supplier for this purchase order';
COMMENT ON COLUMN purchasing.purchaseorders.OrderDate IS 'Date that this purchase order was raised';
COMMENT ON COLUMN purchasing.purchaseorders.DeliveryMethodID IS 'How this purchase order should be delivered';
COMMENT ON COLUMN purchasing.purchaseorders.ContactPersonID IS 'The person who is the primary contact for this purchase order';
COMMENT ON COLUMN purchasing.purchaseorders.ExpectedDeliveryDate IS 'Expected delivery date for this purchase order';
COMMENT ON COLUMN purchasing.purchaseorders.SupplierReference IS 'Supplier reference for our organization (might be our account number at the supplier)';
COMMENT ON COLUMN purchasing.purchaseorders.IsOrderFinalized IS 'Is this purchase order now considered finalized?';
COMMENT ON COLUMN purchasing.purchaseorders.Comments IS 'Any comments related this purchase order (comments sent to the supplier)';
COMMENT ON COLUMN purchasing.purchaseorders.InternalComments IS 'Any internal comments related this purchase order (comments for internal reference only and not sent to the supplier)';
