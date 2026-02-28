-- =============================================
-- Clublabs Intelligence - Stream Configuration
-- CDC tracking on RAW tables
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- STREAM: Track new records in CHATBOT_LOGS
-- =============================================

CREATE OR REPLACE STREAM RAW.CHATBOT_LOGS_STREAM
    ON TABLE RAW.CHATBOT_LOGS
    APPEND_ONLY = TRUE
    SHOW_INITIAL_ROWS = FALSE
    COMMENT = 'Tracks new chatbot log records for transformation';

-- =============================================
-- STREAM: Track new transcripts
-- =============================================

CREATE OR REPLACE STREAM RAW.TRANSCRIPTS_STREAM
    ON TABLE RAW.CONVERSATION_TRANSCRIPTS
    APPEND_ONLY = TRUE
    SHOW_INITIAL_ROWS = FALSE
    COMMENT = 'Tracks new transcript records for search indexing';

-- =============================================
-- VERIFY STREAMS
-- =============================================

SHOW STREAMS IN SCHEMA RAW;

-- Check stream has data
SELECT SYSTEM$STREAM_HAS_DATA('RAW.CHATBOT_LOGS_STREAM');
SELECT SYSTEM$STREAM_HAS_DATA('RAW.TRANSCRIPTS_STREAM');

SELECT 'Stream configuration complete' AS STATUS;
