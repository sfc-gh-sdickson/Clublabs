# Agent Setup Guide

Complete step-by-step guide to deploy the Clublabs Intelligence Agent.

## Prerequisites

### Required Permissions
- `ACCOUNTADMIN` role (or equivalent privileges)
- `CREATE DATABASE`, `CREATE WAREHOUSE`, `CREATE SCHEMA`
- `CREATE CORTEX SEARCH SERVICE`
- `CREATE CORTEX AGENT`

### Feature Requirements
- Cortex Agent enabled on your Snowflake account
- Cortex Search enabled
- Cortex Analyst enabled

## Step 1: Database and Schema Setup

Run the database setup script:

```sql
-- File: sql/setup/01_database_and_schema.sql

USE ROLE ACCOUNTADMIN;

CREATE DATABASE IF NOT EXISTS CLUBLABS_INTELLIGENCE;
USE DATABASE CLUBLABS_INTELLIGENCE;

CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS STAGING;
CREATE SCHEMA IF NOT EXISTS ANALYTICS;
CREATE SCHEMA IF NOT EXISTS SEMANTIC;
CREATE SCHEMA IF NOT EXISTS SEARCH;
CREATE SCHEMA IF NOT EXISTS MODELS;

CREATE OR REPLACE WAREHOUSE CLUBLABS_WH WITH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;
```

**Verification:**
```sql
SHOW SCHEMAS IN DATABASE CLUBLABS_INTELLIGENCE;
-- Should show: RAW, STAGING, ANALYTICS, SEMANTIC, SEARCH, MODELS
```

## Step 2: Create Tables

Run the table creation script:

```sql
-- File: sql/setup/02_create_tables.sql
-- Creates dimension and fact tables for the star schema
```

**Verification:**
```sql
SHOW TABLES IN SCHEMA ANALYTICS;
-- Should show: DIM_DATE, DIM_MEMBER, DIM_SERVICE_TYPE, DIM_CHANNEL, 
--              DIM_AGENT, FACT_CONVERSATION, FACT_MESSAGE, etc.
```

## Step 3: Load Data

For production, configure Snowpipe to ingest from your ERS chatbot logs.

For development/testing, run synthetic data generation:

```sql
-- File: sql/data/03_generate_synthetic_data.sql
-- Generates 10,000 members, 50,000 conversations, 10,000 transcripts
```

**Verification:**
```sql
SELECT COUNT(*) FROM ANALYTICS.DIM_MEMBER;  -- ~10,000
SELECT COUNT(*) FROM ANALYTICS.FACT_CONVERSATION;  -- ~50,000
SELECT COUNT(*) FROM RAW.CONVERSATION_TRANSCRIPTS;  -- ~10,000
```

## Step 4: Create Analytical Views

```sql
-- File: sql/views/04_create_views.sql
-- Creates views for dashboards and reporting
```

Views created:
- `V_CHATBOT_PERFORMANCE` - Real-time performance dashboard
- `V_ESCALATION_ANALYSIS` - Escalation breakdown
- `V_MEMBER_ENGAGEMENT` - Member behavior analysis
- `V_SERVICE_PERFORMANCE` - Service type metrics
- `V_USER_FUNNEL` - Conversion funnel
- `V_DAILY_TRENDS` - Day-over-day trends
- `V_HOURLY_DISTRIBUTION` - Volume by hour

## Step 5: Create Semantic Views

```sql
-- File: sql/views/05_create_semantic_views.sql
-- Creates semantic views for Cortex Analyst
```

Semantic views created:
- `CHATBOT_CONVERSATIONS_SV` - Conversation analytics
- `DAILY_KPIS_SV` - KPI trend analysis
- `MEMBER_ANALYTICS_SV` - Member segmentation

**Verification:**
```sql
SHOW SEMANTIC VIEWS IN SCHEMA SEMANTIC;
```

## Step 6: Create Cortex Search Services

```sql
-- File: sql/search/06_create_cortex_search.sql
-- Creates search services for transcript retrieval
```

Services created:
- `CONVERSATION_SEARCH_SERVICE` - Search full transcripts
- `RESOLUTION_SEARCH_SERVICE` - Search resolution notes

**Verification:**
```sql
SHOW CORTEX SEARCH SERVICES IN SCHEMA SEARCH;
```

## Step 7: Create Agent Functions

```sql
-- File: sql/models/07_ml_model_functions.sql
-- Creates SQL functions callable by the agent
```

Functions created:
- `GET_CHATBOT_KPIS(start_date, end_date)`
- `GET_ESCALATION_BREAKDOWN(start_date, end_date)`
- `GET_SERVICE_PERFORMANCE(start_date, end_date)`
- `GET_CHANNEL_PERFORMANCE(start_date, end_date)`
- `GET_MEMBER_SEGMENT_ANALYSIS(start_date, end_date)`
- `DETECT_KPI_ANOMALIES(check_date)`

## Step 8: Create the Agent

```sql
-- File: sql/agent/08_create_financial_agent.sql

CREATE OR REPLACE CORTEX AGENT CLUBLABS_INTELLIGENCE_AGENT
  MODEL = 'claude-3-5-sonnet'
  TOOLS = (...)
  SYSTEM_PROMPT = '...'
  COMMENT = 'Clublabs Intelligence Agent for ERS chatbot analytics';
```

**Verification:**
```sql
SHOW CORTEX AGENTS IN SCHEMA SNOWFLAKE_INTELLIGENCE.AGENTS;
```

## Step 9: Test the Agent

```sql
-- Basic test
SELECT SNOWFLAKE.CORTEX.AGENT(
    'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
    'What is the current containment rate?'
);

-- KPI overview
SELECT SNOWFLAKE.CORTEX.AGENT(
    'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
    'Give me a summary of chatbot KPIs for the last 7 days'
);

-- Transcript search
SELECT SNOWFLAKE.CORTEX.AGENT(
    'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
    'Find conversations about towing service issues'
);
```

## Troubleshooting

### Common Issues

**Error: "Cortex Agent feature not enabled"**
- Contact Snowflake support to enable Cortex Agent for your account

**Error: "Insufficient privileges"**
- Ensure you're using ACCOUNTADMIN or have been granted necessary privileges

**Error: "Semantic view not found"**
- Verify semantic views were created: `SHOW SEMANTIC VIEWS IN SCHEMA SEMANTIC`

**Slow response times**
- Increase warehouse size
- Check if Cortex Search services are synchronized

### Support

For issues, contact the Clublabs Data Platform team.
