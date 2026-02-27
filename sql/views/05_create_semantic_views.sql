-- =============================================
-- Clublabs Intelligence Agent - Semantic Views
-- Step 5: Create semantic views for Cortex Analyst
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- SEMANTIC VIEW: Chatbot Conversations
-- For natural language queries about conversations
-- =============================================

CREATE OR REPLACE SEMANTIC VIEW SEMANTIC.CHATBOT_CONVERSATIONS_SV
  TABLES (
    ANALYTICS.FACT_CONVERSATION AS CONVERSATIONS
      PRIMARY KEY (CONVERSATION_KEY)
      WITH SYNONYMS ('chats', 'interactions', 'sessions', 'chat sessions')
      WITH METRICS (
        TOTAL_CONVERSATIONS AS COUNT(CONVERSATION_KEY)
          WITH SYNONYMS ('conversation count', 'chat count', 'number of conversations'),
        AVG_DURATION_MINUTES AS AVG(DURATION_SECONDS) / 60.0
          WITH SYNONYMS ('average duration', 'avg chat length', 'mean duration'),
        CONTAINMENT_RATE AS SUM(CASE WHEN WAS_ESCALATED THEN 0 ELSE 1 END)::FLOAT / NULLIF(COUNT(*), 0)
          WITH SYNONYMS ('bot containment', 'self-service rate', 'automation rate'),
        ESCALATION_RATE AS SUM(CASE WHEN WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0)
          WITH SYNONYMS ('handoff rate', 'transfer rate'),
        FCR_RATE AS SUM(CASE WHEN FIRST_CONTACT_RESOLUTION THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0)
          WITH SYNONYMS ('first contact resolution rate', 'first call resolution'),
        AVG_SENTIMENT AS AVG(SENTIMENT_SCORE)
          WITH SYNONYMS ('average sentiment', 'mean sentiment score'),
        AVG_CSAT AS AVG(CSAT_SCORE)
          WITH SYNONYMS ('average satisfaction', 'customer satisfaction score')
      )
      WITH FILTERS (
        CHANNEL_KEY WITH SYNONYMS ('channel', 'contact channel'),
        SERVICE_TYPE_KEY WITH SYNONYMS ('service type', 'request type'),
        WAS_ESCALATED WITH SYNONYMS ('escalated', 'transferred', 'handed off'),
        SENTIMENT_LABEL WITH SYNONYMS ('sentiment', 'customer mood')
      ),
    
    ANALYTICS.DIM_DATE AS DATES
      PRIMARY KEY (DATE_KEY)
      WITH SYNONYMS ('calendar', 'time')
      WITH FILTERS (
        FULL_DATE WITH SYNONYMS ('date', 'day'),
        MONTH_NAME WITH SYNONYMS ('month'),
        QUARTER WITH SYNONYMS ('quarter', 'Q'),
        YEAR WITH SYNONYMS ('year'),
        IS_WEEKEND WITH SYNONYMS ('weekend', 'weekday')
      ),
    
    ANALYTICS.DIM_CHANNEL AS CHANNELS
      PRIMARY KEY (CHANNEL_KEY)
      WITH SYNONYMS ('contact channels', 'touchpoints')
      WITH FILTERS (
        CHANNEL_NAME WITH SYNONYMS ('channel', 'channel type'),
        IS_DIGITAL WITH SYNONYMS ('digital channel', 'online')
      ),
    
    ANALYTICS.DIM_SERVICE_TYPE AS SERVICE_TYPES
      PRIMARY KEY (SERVICE_TYPE_KEY)
      WITH SYNONYMS ('services', 'request types', 'intents')
      WITH FILTERS (
        SERVICE_NAME WITH SYNONYMS ('service', 'service type'),
        SERVICE_CATEGORY WITH SYNONYMS ('category', 'service category'),
        IS_EMERGENCY WITH SYNONYMS ('emergency', 'urgent')
      ),
    
    ANALYTICS.DIM_MEMBER AS MEMBERS
      PRIMARY KEY (MEMBER_KEY)
      WITH SYNONYMS ('customers', 'users', 'subscribers')
      WITH FILTERS (
        MEMBERSHIP_TYPE WITH SYNONYMS ('membership', 'tier', 'plan'),
        REGION WITH SYNONYMS ('region', 'area'),
        STATE WITH SYNONYMS ('state', 'location'),
        AGE_GROUP WITH SYNONYMS ('age', 'age range', 'demographic')
      )
  )
  RELATIONSHIPS (
    CONVERSATIONS (DATE_KEY) REFERENCES DATES (DATE_KEY),
    CONVERSATIONS (CHANNEL_KEY) REFERENCES CHANNELS (CHANNEL_KEY),
    CONVERSATIONS (SERVICE_TYPE_KEY) REFERENCES SERVICE_TYPES (SERVICE_TYPE_KEY),
    CONVERSATIONS (MEMBER_KEY) REFERENCES MEMBERS (MEMBER_KEY)
  )
  COMMENT = 'Semantic view for analyzing ERS chatbot conversations, performance metrics, and member interactions';

-- =============================================
-- SEMANTIC VIEW: Daily KPIs
-- For trend analysis and executive dashboards
-- =============================================

CREATE OR REPLACE SEMANTIC VIEW SEMANTIC.DAILY_KPIS_SV
  TABLES (
    ANALYTICS.FACT_DAILY_KPI AS DAILY_METRICS
      PRIMARY KEY (KPI_KEY)
      WITH SYNONYMS ('daily stats', 'daily performance', 'KPIs')
      WITH METRICS (
        TOTAL_CONVERSATIONS AS SUM(TOTAL_CONVERSATIONS)
          WITH SYNONYMS ('conversations', 'total chats'),
        TOTAL_MESSAGES AS SUM(TOTAL_MESSAGES)
          WITH SYNONYMS ('messages', 'message volume'),
        BOT_HANDLED AS SUM(BOT_HANDLED_COUNT)
          WITH SYNONYMS ('bot resolved', 'self-service'),
        ESCALATIONS AS SUM(ESCALATED_COUNT)
          WITH SYNONYMS ('transfers', 'handoffs'),
        ABANDONMENTS AS SUM(ABANDONED_COUNT)
          WITH SYNONYMS ('abandoned', 'dropped'),
        CONTAINMENT_RATE AS SUM(BOT_HANDLED_COUNT)::FLOAT / NULLIF(SUM(TOTAL_CONVERSATIONS), 0)
          WITH SYNONYMS ('self-service rate', 'bot containment rate'),
        AVG_DURATION AS AVG(AVG_DURATION_SECONDS) / 60.0
          WITH SYNONYMS ('average duration minutes', 'avg chat length'),
        AVG_RESPONSE_TIME AS AVG(AVG_RESPONSE_TIME_SECONDS)
          WITH SYNONYMS ('response time', 'avg response time'),
        AVG_CSAT AS AVG(AVG_CSAT_SCORE)
          WITH SYNONYMS ('satisfaction', 'CSAT score'),
        AVG_SENTIMENT AS AVG(AVG_SENTIMENT_SCORE)
          WITH SYNONYMS ('sentiment', 'customer sentiment')
      ),
    
    ANALYTICS.DIM_DATE AS DATES
      PRIMARY KEY (DATE_KEY)
      WITH FILTERS (
        FULL_DATE WITH SYNONYMS ('date'),
        MONTH_NAME WITH SYNONYMS ('month'),
        QUARTER WITH SYNONYMS ('quarter'),
        YEAR WITH SYNONYMS ('year'),
        WEEK_OF_YEAR WITH SYNONYMS ('week')
      ),
    
    ANALYTICS.DIM_CHANNEL AS CHANNELS
      PRIMARY KEY (CHANNEL_KEY)
      WITH FILTERS (
        CHANNEL_NAME WITH SYNONYMS ('channel')
      ),
    
    ANALYTICS.DIM_SERVICE_TYPE AS SERVICE_TYPES
      PRIMARY KEY (SERVICE_TYPE_KEY)
      WITH FILTERS (
        SERVICE_CATEGORY WITH SYNONYMS ('service category'),
        SERVICE_NAME WITH SYNONYMS ('service')
      )
  )
  RELATIONSHIPS (
    DAILY_METRICS (DATE_KEY) REFERENCES DATES (DATE_KEY),
    DAILY_METRICS (CHANNEL_KEY) REFERENCES CHANNELS (CHANNEL_KEY),
    DAILY_METRICS (SERVICE_TYPE_KEY) REFERENCES SERVICE_TYPES (SERVICE_TYPE_KEY)
  )
  COMMENT = 'Semantic view for daily KPI trends and performance monitoring';

-- =============================================
-- SEMANTIC VIEW: Member Analytics
-- For member behavior and engagement analysis
-- =============================================

CREATE OR REPLACE SEMANTIC VIEW SEMANTIC.MEMBER_ANALYTICS_SV
  TABLES (
    ANALYTICS.V_MEMBER_ENGAGEMENT AS MEMBER_ENGAGEMENT
      PRIMARY KEY (MEMBER_ID)
      WITH SYNONYMS ('member activity', 'customer engagement')
      WITH METRICS (
        TOTAL_MEMBERS AS COUNT(DISTINCT MEMBER_ID)
          WITH SYNONYMS ('member count', 'customer count'),
        TOTAL_INTERACTIONS AS SUM(TOTAL_INTERACTIONS)
          WITH SYNONYMS ('interactions', 'engagements'),
        AVG_INTERACTIONS_PER_MEMBER AS AVG(TOTAL_INTERACTIONS)
          WITH SYNONYMS ('avg interactions', 'engagement rate'),
        AVG_SENTIMENT AS AVG(AVG_SENTIMENT)
          WITH SYNONYMS ('average sentiment', 'member sentiment'),
        AVG_CSAT AS AVG(AVG_CSAT)
          WITH SYNONYMS ('average satisfaction', 'member satisfaction'),
        ESCALATION_COUNT AS SUM(ESCALATION_COUNT)
          WITH SYNONYMS ('escalations', 'transfers'),
        FCR_COUNT AS SUM(FCR_COUNT)
          WITH SYNONYMS ('first contact resolutions', 'FCR')
      )
      WITH FILTERS (
        MEMBERSHIP_TYPE WITH SYNONYMS ('membership', 'tier'),
        REGION WITH SYNONYMS ('region'),
        STATE WITH SYNONYMS ('state'),
        AGE_GROUP WITH SYNONYMS ('age group', 'demographic'),
        TENURE_MONTHS WITH SYNONYMS ('tenure', 'member tenure')
      )
  )
  COMMENT = 'Semantic view for member engagement and behavior analysis';

-- Grant permissions on semantic views
GRANT USAGE ON SEMANTIC VIEW SEMANTIC.CHATBOT_CONVERSATIONS_SV TO ROLE PUBLIC;
GRANT USAGE ON SEMANTIC VIEW SEMANTIC.DAILY_KPIS_SV TO ROLE PUBLIC;
GRANT USAGE ON SEMANTIC VIEW SEMANTIC.MEMBER_ANALYTICS_SV TO ROLE PUBLIC;

SELECT 'Semantic views created successfully' AS STATUS;
