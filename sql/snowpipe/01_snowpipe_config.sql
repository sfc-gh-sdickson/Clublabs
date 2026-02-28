-- =============================================
-- Clublabs Intelligence - Snowpipe Configuration
-- Continuous ingestion from AWS S3
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- STORAGE INTEGRATION (AWS S3)
-- =============================================

CREATE OR REPLACE STORAGE INTEGRATION CLUBLABS_S3_INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<AWS_ACCOUNT_ID>:role/clublabs-snowflake-role'
    STORAGE_ALLOWED_LOCATIONS = (
        's3://clublabs-logs-us-east-1/',
        's3://clublabs-logs-us-west-2/'
    );

-- Describe integration to get AWS IAM user for trust policy
DESC INTEGRATION CLUBLABS_S3_INTEGRATION;

-- =============================================
-- EXTERNAL STAGES (One per region)
-- =============================================

CREATE OR REPLACE STAGE RAW.S3_STAGE_US_EAST_1
    STORAGE_INTEGRATION = CLUBLABS_S3_INTEGRATION
    URL = 's3://clublabs-logs-us-east-1/ers-chatbot/'
    FILE_FORMAT = (TYPE = 'JSON' COMPRESSION = 'GZIP');

CREATE OR REPLACE STAGE RAW.S3_STAGE_US_WEST_2
    STORAGE_INTEGRATION = CLUBLABS_S3_INTEGRATION
    URL = 's3://clublabs-logs-us-west-2/ers-chatbot/'
    FILE_FORMAT = (TYPE = 'JSON' COMPRESSION = 'GZIP');

-- =============================================
-- SNOWPIPE: US-EAST-1 Region
-- =============================================

CREATE OR REPLACE PIPE RAW.PIPE_US_EAST_1
    AUTO_INGEST = TRUE
    AS
    COPY INTO RAW.CHATBOT_LOGS (
        LOG_ID,
        TIMESTAMP,
        SESSION_ID,
        MEMBER_ID,
        EVENT_TYPE,
        EVENT_DATA,
        CHANNEL,
        RAW_PAYLOAD,
        INGESTED_AT
    )
    FROM (
        SELECT 
            $1:log_id::VARCHAR,
            $1:timestamp::TIMESTAMP_NTZ,
            $1:session_id::VARCHAR,
            $1:member_id::VARCHAR,
            $1:event_type::VARCHAR,
            $1:event_data::VARIANT,
            $1:channel::VARCHAR,
            $1,
            CURRENT_TIMESTAMP()
        FROM @RAW.S3_STAGE_US_EAST_1
    );

-- =============================================
-- SNOWPIPE: US-WEST-2 Region
-- =============================================

CREATE OR REPLACE PIPE RAW.PIPE_US_WEST_2
    AUTO_INGEST = TRUE
    AS
    COPY INTO RAW.CHATBOT_LOGS (
        LOG_ID,
        TIMESTAMP,
        SESSION_ID,
        MEMBER_ID,
        EVENT_TYPE,
        EVENT_DATA,
        CHANNEL,
        RAW_PAYLOAD,
        INGESTED_AT
    )
    FROM (
        SELECT 
            $1:log_id::VARCHAR,
            $1:timestamp::TIMESTAMP_NTZ,
            $1:session_id::VARCHAR,
            $1:member_id::VARCHAR,
            $1:event_type::VARCHAR,
            $1:event_data::VARIANT,
            $1:channel::VARCHAR,
            $1,
            CURRENT_TIMESTAMP()
        FROM @RAW.S3_STAGE_US_WEST_2
    );

-- =============================================
-- GET SQS NOTIFICATION CHANNEL ARN
-- (Configure this in AWS S3 bucket event notifications)
-- =============================================

SHOW PIPES IN SCHEMA RAW;

-- After running, copy the notification_channel value and configure
-- S3 bucket event notifications to send to that SQS queue

-- =============================================
-- MONITORING QUERIES
-- =============================================

-- Check pipe status
SELECT SYSTEM$PIPE_STATUS('RAW.PIPE_US_EAST_1');
SELECT SYSTEM$PIPE_STATUS('RAW.PIPE_US_WEST_2');

-- View copy history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
    TABLE_NAME => 'RAW.CHATBOT_LOGS',
    START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
))
ORDER BY LAST_LOAD_TIME DESC;

-- Check for errors
SELECT *
FROM TABLE(VALIDATE_PIPE_LOAD(
    PIPE_NAME => 'RAW.PIPE_US_EAST_1',
    START_TIME => DATEADD(HOURS, -24, CURRENT_TIMESTAMP())
));

SELECT 'Snowpipe configuration complete' AS STATUS;
