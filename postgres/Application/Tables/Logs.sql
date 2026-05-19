CREATE SCHEMA IF NOT EXISTS application;

-- COLUMNSTORE index omitted: no PostgreSQL equivalent
CREATE TABLE application.logs (
    Message   VARCHAR(4000) NOT NULL,
    Level     VARCHAR(16)   NOT NULL,
    EventTime TIMESTAMP(6)  NOT NULL,
    LogEvent  TEXT          NULL
);

COMMENT ON TABLE application.logs IS 'Application logs that are stored in database';
COMMENT ON COLUMN application.logs.Message IS 'Logged message';
COMMENT ON COLUMN application.logs.Level IS 'Severity of the log entry';
COMMENT ON COLUMN application.logs.EventTime IS 'Time when the record is logged';
COMMENT ON COLUMN application.logs.LogEvent IS 'Details about the logged event';
