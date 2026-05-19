CREATE SCHEMA IF NOT EXISTS application;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.transaction_type_id_seq START 1 INCREMENT 1;

CREATE TABLE application.transactiontypes (
    TransactionTypeID   INTEGER      DEFAULT nextval('sequences.transaction_type_id_seq') NOT NULL,
    TransactionTypeName VARCHAR(50)  NOT NULL,
    LastEditedBy        INTEGER      NOT NULL,
    ValidFrom           TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo             TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_TransactionTypes PRIMARY KEY (TransactionTypeID),
    CONSTRAINT FK_Application_TransactionTypes_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID),
    CONSTRAINT UQ_Application_TransactionTypes_TransactionTypeName UNIQUE (TransactionTypeName)
);

COMMENT ON TABLE application.transactiontypes IS 'Types of customer, supplier, or stock transactions (ie: invoice, credit note, etc.)';
COMMENT ON COLUMN application.transactiontypes.TransactionTypeID IS 'Numeric ID used for reference to a transaction type within the database';
COMMENT ON COLUMN application.transactiontypes.TransactionTypeName IS 'Full name of the transaction type';
