CREATE SCHEMA IF NOT EXISTS application;
CREATE SCHEMA IF NOT EXISTS sequences;

CREATE SEQUENCE IF NOT EXISTS sequences.person_id_seq START 1 INCREMENT 1;

CREATE TABLE application.people (
    PersonID                INTEGER                  DEFAULT nextval('sequences.person_id_seq') NOT NULL,
    FullName                VARCHAR(50)              NOT NULL,
    PreferredName           VARCHAR(50)              NOT NULL,
    SearchName              VARCHAR(101)             GENERATED ALWAYS AS (PreferredName || ' ' || FullName) STORED NOT NULL,
    IsPermittedToLogon      BOOLEAN                  NOT NULL,
    LogonName               VARCHAR(256)             NULL,
    IsExternalLogonProvider BOOLEAN                  NOT NULL,
    HashedPassword          BYTEA                    NULL,
    IsSystemUser            BOOLEAN                  NOT NULL,
    IsEmployee              BOOLEAN                  NOT NULL,
    IsSalesperson           BOOLEAN                  NOT NULL,
    UserPreferences         TEXT                     NULL,
    PhoneNumber             VARCHAR(20)              NULL,
    FaxNumber               VARCHAR(20)              NULL,
    EmailAddress            VARCHAR(256)             NULL,
    Photo                   BYTEA                    NULL,
    CustomFields            TEXT                     NULL,
    OtherLanguages          TEXT                     NULL, -- NOTE: was a non-persisted computed column (json_query on CustomFields)
    LastEditedBy            INTEGER                  NOT NULL,
    ValidFrom               TIMESTAMP(6)             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ValidTo                 TIMESTAMP(6)             NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT PK_Application_People PRIMARY KEY (PersonID),
    CONSTRAINT FK_Application_People_Application_People FOREIGN KEY (LastEditedBy) REFERENCES application.people (PersonID)
);

CREATE INDEX IX_Application_People_IsEmployee
    ON application.people (IsEmployee ASC);

CREATE INDEX IX_Application_People_IsSalesperson
    ON application.people (IsSalesperson ASC);

CREATE INDEX IX_Application_People_FullName
    ON application.people (FullName ASC);

CREATE INDEX IX_Application_People_Perf_20160301_05
    ON application.people (IsPermittedToLogon ASC, PersonID ASC)
    INCLUDE (FullName, EmailAddress);

COMMENT ON TABLE application.people IS 'People known to the application (staff, customer contacts, supplier contacts)';
COMMENT ON COLUMN application.people.PersonID IS 'Numeric ID used for reference to a person within the database';
COMMENT ON COLUMN application.people.FullName IS 'Full name for this person';
COMMENT ON COLUMN application.people.PreferredName IS 'Name that this person prefers to be called';
COMMENT ON COLUMN application.people.SearchName IS 'Name to build full text search on (computed column)';
COMMENT ON COLUMN application.people.IsPermittedToLogon IS 'Is this person permitted to log on?';
COMMENT ON COLUMN application.people.LogonName IS 'Person''s system logon name';
COMMENT ON COLUMN application.people.IsExternalLogonProvider IS 'Is logon token provided by an external system?';
COMMENT ON COLUMN application.people.HashedPassword IS 'Hash of password for users without external logon tokens';
COMMENT ON COLUMN application.people.IsSystemUser IS 'Is the currently permitted to make online access?';
COMMENT ON COLUMN application.people.IsEmployee IS 'Is this person an employee?';
COMMENT ON COLUMN application.people.IsSalesperson IS 'Is this person a staff salesperson?';
COMMENT ON COLUMN application.people.UserPreferences IS 'User preferences related to the website (holds JSON data)';
COMMENT ON COLUMN application.people.PhoneNumber IS 'Phone number';
COMMENT ON COLUMN application.people.FaxNumber IS 'Fax number';
COMMENT ON COLUMN application.people.EmailAddress IS 'Email address for this person';
COMMENT ON COLUMN application.people.Photo IS 'Photo of this person';
COMMENT ON COLUMN application.people.CustomFields IS 'Custom fields for employees and salespeople';
COMMENT ON COLUMN application.people.OtherLanguages IS 'Other languages spoken (computed column from custom fields)';
