CREATE SCHEMA IF NOT EXISTS application;

CREATE TABLE application.people_archive (
    PersonID                INTEGER         NOT NULL,
    FullName                VARCHAR(50)     NOT NULL,
    PreferredName           VARCHAR(50)     NOT NULL,
    SearchName              VARCHAR(101)    NOT NULL,
    IsPermittedToLogon      BOOLEAN         NOT NULL,
    LogonName               VARCHAR(256)    NULL,
    IsExternalLogonProvider BOOLEAN         NOT NULL,
    HashedPassword          BYTEA           NULL,
    IsSystemUser            BOOLEAN         NOT NULL,
    IsEmployee              BOOLEAN         NOT NULL,
    IsSalesperson           BOOLEAN         NOT NULL,
    UserPreferences         TEXT            NULL,
    PhoneNumber             VARCHAR(20)     NULL,
    FaxNumber               VARCHAR(20)     NULL,
    EmailAddress            VARCHAR(256)    NULL,
    Photo                   BYTEA           NULL,
    CustomFields            TEXT            NULL,
    OtherLanguages          TEXT            NULL,
    LastEditedBy            INTEGER         NOT NULL,
    ValidFrom               TIMESTAMP(6)    NOT NULL,
    ValidTo                 TIMESTAMP(6)    NOT NULL
);

CREATE INDEX ix_People_Archive ON application.people_archive (ValidTo ASC, ValidFrom ASC);
