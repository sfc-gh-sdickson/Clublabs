-- =============================================
-- Clublabs Intelligence Agent - Cortex Search
-- Step 6: Create Cortex Search service for transcripts
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- CORTEX SEARCH SERVICE: Conversation Transcripts
-- Enables semantic search over chat transcripts
-- =============================================

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.CONVERSATION_SEARCH_SERVICE
  ON FULL_TRANSCRIPT
  ATTRIBUTES SERVICE_CATEGORY, RESOLUTION_NOTES, TRANSCRIPT_SUMMARY
  WAREHOUSE = CLUBLABS_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      TRANSCRIPT_ID,
      CONVERSATION_ID,
      MEMBER_ID,
      FULL_TRANSCRIPT,
      TRANSCRIPT_SUMMARY,
      SERVICE_CATEGORY,
      RESOLUTION_NOTES,
      CONVERSATION_DATE
    FROM RAW.CONVERSATION_TRANSCRIPTS
  );

-- =============================================
-- CORTEX SEARCH SERVICE: Resolution Knowledge Base
-- Search for resolution patterns and solutions
-- =============================================

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.RESOLUTION_SEARCH_SERVICE
  ON RESOLUTION_NOTES
  ATTRIBUTES SERVICE_CATEGORY, TRANSCRIPT_SUMMARY
  WAREHOUSE = CLUBLABS_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT 
      TRANSCRIPT_ID,
      CONVERSATION_ID,
      SERVICE_CATEGORY,
      TRANSCRIPT_SUMMARY,
      RESOLUTION_NOTES,
      CONVERSATION_DATE
    FROM RAW.CONVERSATION_TRANSCRIPTS
    WHERE RESOLUTION_NOTES IS NOT NULL
  );

-- Grant permissions
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH.CONVERSATION_SEARCH_SERVICE TO ROLE PUBLIC;
GRANT USAGE ON CORTEX SEARCH SERVICE SEARCH.RESOLUTION_SEARCH_SERVICE TO ROLE PUBLIC;

SELECT 'Cortex Search services created successfully' AS STATUS;
