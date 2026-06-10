CREATE SCHEMA IF NOT EXISTS webapi;

CREATE OR REPLACE VIEW webapi.transaction_types AS
SELECT TransactionTypeID, TransactionTypeName
FROM application.transactiontypes;
