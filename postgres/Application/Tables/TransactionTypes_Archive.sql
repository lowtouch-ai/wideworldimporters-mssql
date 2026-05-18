CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.transaction_types_archive (
    TransactionTypeID   INTEGER       NOT NULL,
    TransactionTypeName VARCHAR(50)   NOT NULL,
    LastEditedBy        INTEGER       NOT NULL,
    ValidFrom           TIMESTAMP(6)  NOT NULL,
    ValidTo             TIMESTAMP(6)  NOT NULL
);

CREATE INDEX ix_TransactionTypes_Archive ON application.transaction_types_archive (ValidTo ASC, ValidFrom ASC);
