# Clublabs Intelligence Agent

An AI-powered analytics agent for ERS (Emergency Roadside Services) chatbot performance analysis, built on Snowflake Cortex.

## Overview

The Clublabs Intelligence Agent provides:
- **Natural Language Analytics**: Query chatbot performance data using plain English
- **Transcript Search**: Semantic search over conversation transcripts
- **KPI Monitoring**: Track containment rate, escalation rate, CSAT, and sentiment
- **Anomaly Detection**: Automatic detection of unusual patterns in metrics
- **Member Insights**: Segment analysis by membership tier and region

## Architecture

![System Architecture](docs/images/architecture.svg)

## Quick Start

### Prerequisites
- Snowflake account with ACCOUNTADMIN role
- Cortex Agent feature enabled
- X-Small warehouse (or larger)

### Installation

Run the SQL files in order (see deployment diagram below):

![Deployment Flow](docs/images/deployment_flow.svg)

**SQL Files:**

| Step | File | Description |
|------|------|-------------|
| 1 | `sql/setup/01_database_and_schema.sql` | Database, schemas, warehouse |
| 2 | `sql/setup/02_create_tables.sql` | All table definitions |
| 3 | `sql/data/03_generate_synthetic_data.sql` | Test data generation |
| 4 | `sql/views/04_create_views.sql` | Analytical views |
| 5 | `sql/views/05_create_semantic_views.sql` | Semantic views |
| 6 | `sql/search/06_create_cortex_search.sql` | Cortex Search services |
| 7 | `sql/models/07_ml_model_functions.sql` | Agent tool functions |
| 8 | `sql/agent/08_create_financial_agent.sql` | Agent creation |

## Usage

### Query the Agent

```sql
SELECT SNOWFLAKE.CORTEX.AGENT(
    'SNOWFLAKE_INTELLIGENCE.AGENTS.CLUBLABS_INTELLIGENCE_AGENT',
    'What was our containment rate last month?'
);
```

### Sample Questions

**Performance Metrics:**
- "What's our current containment rate?"
- "Show me the escalation breakdown for last week"
- "Compare CSAT scores across channels"

**Trend Analysis:**
- "How has sentiment trended over the past 30 days?"
- "Which service types have the highest escalation rates?"
- "Are there any anomalies in yesterday's metrics?"

**Transcript Search:**
- "Find conversations about battery jump issues"
- "Search for complaints about wait times"
- "Show me examples of high-sentiment conversations"

## Key Metrics

| Metric | Description | Target |
|--------|-------------|--------|
| Containment Rate | % handled by bot without escalation | >75% |
| FCR Rate | First Contact Resolution | >70% |
| CSAT Score | Customer Satisfaction (1-5) | >4.0 |
| Avg Handle Time | Conversation duration | <10 min |
| Sentiment | Customer sentiment (-1 to 1) | >0.2 |

## Data Model

### Fact Tables
| Table | Description |
|-------|-------------|
| `FACT_CONVERSATION` | Main conversation metrics |
| `FACT_MESSAGE` | Message-level details |
| `FACT_USER_JOURNEY` | Funnel tracking |
| `FACT_DAILY_KPI` | Aggregated daily metrics |

### Dimension Tables
| Table | Description |
|-------|-------------|
| `DIM_DATE` | Calendar dimension |
| `DIM_MEMBER` | Member attributes |
| `DIM_SERVICE_TYPE` | Service categories |
| `DIM_CHANNEL` | Contact channels |
| `DIM_AGENT` | Bot and human agents |

## ML Models

![ML Pipeline](docs/images/ml_models.svg)

## Documentation

- [Agent Setup Guide](docs/AGENT_SETUP.md) - Step-by-step deployment
- [Deployment Summary](docs/DEPLOYMENT_SUMMARY.md) - Current status
- [Test Questions](docs/questions.md) - 60+ validation queries

## License

Internal use only - Clublabs Corporation
