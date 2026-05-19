CREATE SCHEMA IF NOT EXISTS dbo;

CREATE TABLE dbo.sampleversion
(
    MajorSampleVersion INTEGER       NOT NULL,
    MinorSampleVersion INTEGER       NOT NULL,
    MinSQLServerBuild  VARCHAR(25)   NOT NULL,
    RowCount           INTEGER       NOT NULL DEFAULT 1,
    CONSTRAINT uq_SampleVersion_RowCount UNIQUE (RowCount),
    CONSTRAINT chk_SampleVersion_Cardinality CHECK (RowCount = 1)
);
