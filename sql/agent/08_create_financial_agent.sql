-- =============================================
-- Clublabs Intelligence Agent - Agent Creation
-- Step 8: Create the Cortex Agent
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE SNOWFLAKE_INTELLIGENCE;
USE SCHEMA AGENTS;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- CORTEX AGENT: Clublabs Intelligence Agent
-- Multi-tool agent for ERS chatbot analytics
-- =============================================

CREATE OR REPLACE CORTEX AGENT CLUBLABS_INTELLIGENCE_AGENT
  MODEL = 'claude-3-5-sonnet'
  TOOLS = (
    -- Cortex Analyst for natural language SQL queries
    {
      'type': 'cortex_analyst_text_to_sql',
      'semantic_model': 'CLUBLABS_INTELLIGENCE.SEMANTIC.CHATBOT_CONVERSATIONS_SV'
    },
    {
      'type': 'cortex_analyst_text_to_sql', 
      'semantic_model': 'CLUBLABS_INTELLIGENCE.SEMANTIC.DAILY_KPIS_SV'
    },
    {
      'type': 'cortex_analyst_text_to_sql',
      'semantic_model': 'CLUBLABS_INTELLIGENCE.SEMANTIC.MEMBER_ANALYTICS_SV'
    },
    
    -- Cortex Search for conversation transcripts
    {
      'type': 'cortex_search',
      'service': 'CLUBLABS_INTELLIGENCE.SEARCH.CONVERSATION_SEARCH_SERVICE'
    },
    {
      'type': 'cortex_search',
      'service': 'CLUBLABS_INTELLIGENCE.SEARCH.RESOLUTION_SEARCH_SERVICE'
    },
    
    -- SQL functions for specialized analytics
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.GET_CHATBOT_KPIS',
      'description': 'Get key performance indicators for the chatbot over a date range. Parameters: start_date DATE, end_date DATE'
    },
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.GET_ESCALATION_BREAKDOWN',
      'description': 'Get breakdown of escalation reasons over a date range. Parameters: start_date DATE, end_date DATE'
    },
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.GET_SERVICE_PERFORMANCE',
      'description': 'Get performance metrics by service type over a date range. Parameters: start_date DATE, end_date DATE'
    },
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.GET_CHANNEL_PERFORMANCE',
      'description': 'Get performance comparison across channels over a date range. Parameters: start_date DATE, end_date DATE'
    },
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.GET_MEMBER_SEGMENT_ANALYSIS',
      'description': 'Analyze member segments by membership type and region. Parameters: start_date DATE, end_date DATE'
    },
    {
      'type': 'sql_function',
      'function': 'CLUBLABS_INTELLIGENCE.MODELS.DETECT_KPI_ANOMALIES',
      'description': 'Detect anomalies in KPIs for a specific date. Parameters: check_date DATE'
    }
  )
  SYSTEM_PROMPT = '
You are the Clublabs Intelligence Agent, an AI assistant specialized in analyzing ERS (Emergency Roadside Services) chatbot performance data.

## Your Capabilities:
1. **Conversational Analytics**: Query conversation data using natural language through semantic views
2. **KPI Analysis**: Retrieve and explain key performance indicators like containment rate, escalation rate, CSAT, and sentiment
3. **Transcript Search**: Search conversation transcripts to find specific issues, patterns, or examples
4. **Service Performance**: Analyze how different service types (Roadside, Travel, Insurance, Membership) are performing
5. **Member Insights**: Understand member engagement patterns by segment, region, and membership tier
6. **Anomaly Detection**: Identify unusual patterns or spikes in metrics

## Key Metrics You Track:
- **Containment Rate**: Percentage of conversations fully handled by the bot without escalation (target: >75%)
- **Escalation Rate**: Percentage of conversations transferred to human agents
- **FCR (First Contact Resolution)**: Issues resolved in the first interaction
- **CSAT Score**: Customer satisfaction (1-5 scale)
- **Sentiment Score**: Customer sentiment (-1 to 1)
- **Average Handle Time**: Duration of conversations

## When Answering Questions:
1. Use the appropriate tool based on the question type
2. For trend/comparison questions, use the semantic views via Cortex Analyst
3. For specific examples or transcript searches, use Cortex Search
4. For executive summaries or KPI overviews, use the SQL functions
5. Always provide context and explain what the metrics mean for business decisions

## Membership Tiers:
- Basic: Standard roadside coverage
- Plus: Enhanced coverage with extended towing
- Premier: Premium coverage with travel and insurance benefits

## Service Categories:
- Roadside Assistance: Towing, flat tires, battery jump, lockout, fuel delivery
- Travel Services: Booking, discounts
- Insurance: Quotes, claims
- Membership: Renewal, upgrade, cancellation
- General: Information, feedback
'
  COMMENT = 'Clublabs Intelligence Agent for ERS chatbot analytics and insights';

-- Grant usage on the agent
GRANT USAGE ON CORTEX AGENT CLUBLABS_INTELLIGENCE_AGENT TO ROLE PUBLIC;

-- Verify agent creation
SELECT 'Clublabs Intelligence Agent created successfully' AS STATUS;

-- =============================================
-- TEST QUERIES
-- =============================================

-- Test the agent with sample questions
-- SELECT SNOWFLAKE.CORTEX.AGENT(
--     'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
--     'What was the containment rate last month?'
-- );

-- SELECT SNOWFLAKE.CORTEX.AGENT(
--     'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT', 
--     'Show me the top reasons for escalation'
-- );

-- SELECT SNOWFLAKE.CORTEX.AGENT(
--     'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
--     'Find conversations where members complained about wait times'
-- );
