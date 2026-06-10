CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.buying_group_id_seq START 1 INCREMENT 1;

CREATE TABLE sales.buyinggroups (
    BuyingGroupID   INTEGER                  DEFAULT nextval('sequences.buying_group_id_seq') NOT NULL,
    BuyingGroupName VARCHAR(50)              NOT NULL,
    LastEditedBy    INTEGER                  NOT NULL,
    ValidFrom       TIMESTAMP(6)             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo         TIMESTAMP(6)             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Sales_BuyingGroups PRIMARY KEY (BuyingGroupID),
    CONSTRAINT FK_Sales_BuyingGroups_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Sales_BuyingGroups_BuyingGroupName UNIQUE (BuyingGroupName)
);

COMMENT ON TABLE sales.buyinggroups IS 'Customer organizations can be part of groups that exert greater buying power';
COMMENT ON COLUMN sales.buyinggroups.BuyingGroupID IS 'Numeric ID used for reference to a buying group within the database';
COMMENT ON COLUMN sales.buyinggroups.BuyingGroupName IS 'Full name of a buying group that customers can be members of';
