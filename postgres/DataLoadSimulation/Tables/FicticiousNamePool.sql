CREATE SCHEMA IF NOT EXISTS dataloadsimulation;

CREATE TABLE dataloadsimulation.ficticiousnamepool
(
    FullName      VARCHAR(50),
    PreferredName VARCHAR(25),
    LastName      VARCHAR(25),
    ToEmail       VARCHAR(75)
);
