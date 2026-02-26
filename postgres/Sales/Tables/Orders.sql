CREATE SCHEMA IF NOT EXISTS sales;

CREATE SEQUENCE IF NOT EXISTS sequences.order_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.orders (
    OrderID                     INTEGER        DEFAULT nextval('sequences.order_id_seq') NOT NULL,
    CustomerID                  INTEGER        NOT NULL,
    SalespersonPersonID         INTEGER        NOT NULL,
    PickedByPersonID            INTEGER        NULL,
    ContactPersonID             INTEGER        NOT NULL,
    BackorderOrderID            INTEGER        NULL,
    OrderDate                   DATE           NOT NULL,
    ExpectedDeliveryDate        DATE           NOT NULL,
    CustomerPurchaseOrderNumber VARCHAR(20)    NULL,
    IsUndersupplyBackordered    BOOLEAN        NOT NULL,
    Comments                    TEXT           NULL,
    DeliveryInstructions        TEXT           NULL,
    InternalComments            TEXT           NULL,
    PickingCompletedWhen        TIMESTAMP(6)   NULL,
    LastEditedBy                INTEGER        NOT NULL,
    LastEditedWhen              TIMESTAMP(6)   DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT PK_Sales_Orders PRIMARY KEY (OrderID ASC),
    CONSTRAINT FK_Sales_Orders_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Orders_BackorderOrderID_Sales_Orders FOREIGN KEY (BackorderOrderID) REFERENCES sales.orders (OrderID),
    CONSTRAINT FK_Sales_Orders_ContactPersonID_Application_People FOREIGN KEY (ContactPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Orders_CustomerID_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES sales.customers (CustomerID),
    CONSTRAINT FK_Sales_Orders_PickedByPersonID_Application_People FOREIGN KEY (PickedByPersonID) REFERENCES application.people (PersonID),
    CONSTRAINT FK_Sales_Orders_SalespersonPersonID_Application_People FOREIGN KEY (SalespersonPersonID) REFERENCES application.people (PersonID)
);

CREATE INDEX FK_Sales_Orders_CustomerID
    ON sales.orders (CustomerID ASC);

CREATE INDEX FK_Sales_Orders_SalespersonPersonID
    ON sales.orders (SalespersonPersonID ASC);

CREATE INDEX FK_Sales_Orders_PickedByPersonID
    ON sales.orders (PickedByPersonID ASC);

CREATE INDEX FK_Sales_Orders_ContactPersonID
    ON sales.orders (ContactPersonID ASC);

-- INDEX extended properties omitted (PostgreSQL does not support index comments via standard DDL)

COMMENT ON TABLE sales.orders IS 'Detail of customer orders';

COMMENT ON COLUMN sales.orders.OrderID IS 'Numeric ID used for reference to an order within the database';
COMMENT ON COLUMN sales.orders.CustomerID IS 'Customer for this order';
COMMENT ON COLUMN sales.orders.SalespersonPersonID IS 'Salesperson for this order';
COMMENT ON COLUMN sales.orders.PickedByPersonID IS 'Person who picked this shipment';
COMMENT ON COLUMN sales.orders.ContactPersonID IS 'Customer contact for this order';
COMMENT ON COLUMN sales.orders.BackorderOrderID IS 'If this order is a backorder, this column holds the original order number';
COMMENT ON COLUMN sales.orders.OrderDate IS 'Date that this order was raised';
COMMENT ON COLUMN sales.orders.ExpectedDeliveryDate IS 'Expected delivery date';
COMMENT ON COLUMN sales.orders.CustomerPurchaseOrderNumber IS 'Purchase Order Number received from customer';
COMMENT ON COLUMN sales.orders.IsUndersupplyBackordered IS 'If items cannot be supplied are they backordered?';
COMMENT ON COLUMN sales.orders.Comments IS 'Any comments related to this order (sent to customer)';
COMMENT ON COLUMN sales.orders.DeliveryInstructions IS 'Any comments related to order delivery (sent to customer)';
COMMENT ON COLUMN sales.orders.InternalComments IS 'Any internal comments related to this order (not sent to the customer)';
COMMENT ON COLUMN sales.orders.PickingCompletedWhen IS 'When was picking of the entire order completed?';
