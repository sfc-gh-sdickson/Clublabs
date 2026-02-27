-- =============================================
-- Clublabs Intelligence Agent - ML & Agent Functions
-- Step 7: Create agent tool functions
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- CORTEX FUNCTIONS: Built-in AI capabilities
-- =============================================

-- Function to analyze sentiment of conversation text
CREATE OR REPLACE FUNCTION MODELS.ANALYZE_SENTIMENT(input_text VARCHAR)
RETURNS TABLE (sentiment VARCHAR, score FLOAT, confidence FLOAT)
AS
$$
    SELECT 
        CASE 
            WHEN SNOWFLAKE.CORTEX.SENTIMENT(input_text) < -0.3 THEN 'NEGATIVE'
            WHEN SNOWFLAKE.CORTEX.SENTIMENT(input_text) > 0.3 THEN 'POSITIVE'
            ELSE 'NEUTRAL'
        END AS sentiment,
        SNOWFLAKE.CORTEX.SENTIMENT(input_text) AS score,
        0.85 AS confidence
$$;

-- Function to summarize a conversation
CREATE OR REPLACE FUNCTION MODELS.SUMMARIZE_CONVERSATION(transcript VARCHAR)
RETURNS VARCHAR
AS
$$
    SNOWFLAKE.CORTEX.SUMMARIZE(transcript)
$$;

-- Function to extract key entities from text
CREATE OR REPLACE FUNCTION MODELS.EXTRACT_ENTITIES(input_text VARCHAR)
RETURNS VARIANT
AS
$$
    SNOWFLAKE.CORTEX.EXTRACT_ANSWER(
        input_text, 
        'Extract the following entities if present: member name, location, service requested, vehicle type, membership type. Return as JSON.'
    )
$$;

-- =============================================
-- AGENT TOOL FUNCTIONS
-- Functions callable by the Cortex Agent
-- =============================================

-- Get chatbot KPIs for a date range
CREATE OR REPLACE FUNCTION MODELS.GET_CHATBOT_KPIS(start_date DATE, end_date DATE)
RETURNS TABLE (
    metric_name VARCHAR,
    metric_value FLOAT,
    metric_description VARCHAR
)
AS
$$
    SELECT metric_name, metric_value, metric_description
    FROM (
        SELECT 
            'Total Conversations' AS metric_name,
            COUNT(*)::FLOAT AS metric_value,
            'Total number of chatbot conversations' AS metric_description
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE BETWEEN start_date AND end_date
        
        UNION ALL
        
        SELECT 
            'Containment Rate',
            ROUND(SUM(CASE WHEN WAS_ESCALATED THEN 0 ELSE 1 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2),
            'Percentage of conversations handled by bot without escalation'
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE BETWEEN start_date AND end_date
        
        UNION ALL
        
        SELECT 
            'Average CSAT Score',
            ROUND(AVG(CSAT_SCORE), 2),
            'Average customer satisfaction score (1-5)'
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE BETWEEN start_date AND end_date
        
        UNION ALL
        
        SELECT 
            'Average Sentiment',
            ROUND(AVG(SENTIMENT_SCORE), 3),
            'Average sentiment score (-1 to 1)'
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE BETWEEN start_date AND end_date
        
        UNION ALL
        
        SELECT 
            'FCR Rate',
            ROUND(SUM(CASE WHEN FIRST_CONTACT_RESOLUTION THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2),
            'First Contact Resolution rate percentage'
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE BETWEEN start_date AND end_date
    )
$$;

-- Get escalation breakdown
CREATE OR REPLACE FUNCTION MODELS.GET_ESCALATION_BREAKDOWN(start_date DATE, end_date DATE)
RETURNS TABLE (
    escalation_reason VARCHAR,
    count NUMBER,
    percentage FLOAT,
    avg_sentiment FLOAT
)
AS
$$
    SELECT 
        COALESCE(fc.ESCALATION_REASON, 'Unknown') AS escalation_reason,
        COUNT(*) AS count,
        ROUND(COUNT(*)::FLOAT / SUM(COUNT(*)) OVER () * 100, 2) AS percentage,
        ROUND(AVG(fc.SENTIMENT_SCORE), 3) AS avg_sentiment
    FROM ANALYTICS.FACT_CONVERSATION fc
    JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
    WHERE dd.FULL_DATE BETWEEN start_date AND end_date
    AND fc.WAS_ESCALATED = TRUE
    GROUP BY fc.ESCALATION_REASON
    ORDER BY count DESC
$$;

-- Get service type performance
CREATE OR REPLACE FUNCTION MODELS.GET_SERVICE_PERFORMANCE(start_date DATE, end_date DATE)
RETURNS TABLE (
    service_name VARCHAR,
    service_category VARCHAR,
    total_requests NUMBER,
    containment_rate FLOAT,
    avg_duration_minutes FLOAT,
    avg_csat FLOAT
)
AS
$$
    SELECT 
        dst.SERVICE_NAME,
        dst.SERVICE_CATEGORY,
        COUNT(*) AS total_requests,
        ROUND(SUM(CASE WHEN fc.WAS_ESCALATED THEN 0 ELSE 1 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2) AS containment_rate,
        ROUND(AVG(fc.DURATION_SECONDS) / 60.0, 2) AS avg_duration_minutes,
        ROUND(AVG(fc.CSAT_SCORE), 2) AS avg_csat
    FROM ANALYTICS.FACT_CONVERSATION fc
    JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
    JOIN ANALYTICS.DIM_SERVICE_TYPE dst ON fc.SERVICE_TYPE_KEY = dst.SERVICE_TYPE_KEY
    WHERE dd.FULL_DATE BETWEEN start_date AND end_date
    GROUP BY dst.SERVICE_NAME, dst.SERVICE_CATEGORY
    ORDER BY total_requests DESC
$$;

-- Get channel performance comparison
CREATE OR REPLACE FUNCTION MODELS.GET_CHANNEL_PERFORMANCE(start_date DATE, end_date DATE)
RETURNS TABLE (
    channel_name VARCHAR,
    total_conversations NUMBER,
    containment_rate FLOAT,
    escalation_rate FLOAT,
    avg_sentiment FLOAT,
    avg_csat FLOAT
)
AS
$$
    SELECT 
        dc.CHANNEL_NAME,
        COUNT(*) AS total_conversations,
        ROUND(SUM(CASE WHEN fc.WAS_ESCALATED THEN 0 ELSE 1 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2) AS containment_rate,
        ROUND(SUM(CASE WHEN fc.WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2) AS escalation_rate,
        ROUND(AVG(fc.SENTIMENT_SCORE), 3) AS avg_sentiment,
        ROUND(AVG(fc.CSAT_SCORE), 2) AS avg_csat
    FROM ANALYTICS.FACT_CONVERSATION fc
    JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
    JOIN ANALYTICS.DIM_CHANNEL dc ON fc.CHANNEL_KEY = dc.CHANNEL_KEY
    WHERE dd.FULL_DATE BETWEEN start_date AND end_date
    GROUP BY dc.CHANNEL_NAME
    ORDER BY total_conversations DESC
$$;

-- Get member segment analysis
CREATE OR REPLACE FUNCTION MODELS.GET_MEMBER_SEGMENT_ANALYSIS(start_date DATE, end_date DATE)
RETURNS TABLE (
    membership_type VARCHAR,
    region VARCHAR,
    total_members NUMBER,
    total_interactions NUMBER,
    avg_interactions_per_member FLOAT,
    containment_rate FLOAT,
    avg_csat FLOAT
)
AS
$$
    SELECT 
        dm.MEMBERSHIP_TYPE,
        dm.REGION,
        COUNT(DISTINCT dm.MEMBER_KEY) AS total_members,
        COUNT(*) AS total_interactions,
        ROUND(COUNT(*)::FLOAT / NULLIF(COUNT(DISTINCT dm.MEMBER_KEY), 0), 2) AS avg_interactions_per_member,
        ROUND(SUM(CASE WHEN fc.WAS_ESCALATED THEN 0 ELSE 1 END)::FLOAT / NULLIF(COUNT(*), 0) * 100, 2) AS containment_rate,
        ROUND(AVG(fc.CSAT_SCORE), 2) AS avg_csat
    FROM ANALYTICS.FACT_CONVERSATION fc
    JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
    JOIN ANALYTICS.DIM_MEMBER dm ON fc.MEMBER_KEY = dm.MEMBER_KEY
    WHERE dd.FULL_DATE BETWEEN start_date AND end_date
    GROUP BY dm.MEMBERSHIP_TYPE, dm.REGION
    ORDER BY total_interactions DESC
$$;

-- Detect anomalies in daily metrics
CREATE OR REPLACE FUNCTION MODELS.DETECT_KPI_ANOMALIES(check_date DATE)
RETURNS TABLE (
    metric_name VARCHAR,
    current_value FLOAT,
    avg_value FLOAT,
    std_dev FLOAT,
    z_score FLOAT,
    is_anomaly BOOLEAN,
    anomaly_type VARCHAR
)
AS
$$
    WITH daily_stats AS (
        SELECT 
            COUNT(*) AS conversations,
            SUM(CASE WHEN WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS escalation_rate,
            AVG(SENTIMENT_SCORE) AS avg_sentiment,
            AVG(CSAT_SCORE) AS avg_csat
        FROM ANALYTICS.FACT_CONVERSATION fc
        JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
        WHERE dd.FULL_DATE = check_date
    ),
    historical_stats AS (
        SELECT 
            AVG(cnt) AS avg_conversations, STDDEV(cnt) AS std_conversations,
            AVG(esc) AS avg_escalation, STDDEV(esc) AS std_escalation,
            AVG(sent) AS avg_sentiment, STDDEV(sent) AS std_sentiment,
            AVG(csat) AS avg_csat, STDDEV(csat) AS std_csat
        FROM (
            SELECT 
                dd.FULL_DATE,
                COUNT(*) AS cnt,
                SUM(CASE WHEN WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS esc,
                AVG(SENTIMENT_SCORE) AS sent,
                AVG(CSAT_SCORE) AS csat
            FROM ANALYTICS.FACT_CONVERSATION fc
            JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
            WHERE dd.FULL_DATE BETWEEN DATEADD(DAY, -30, check_date) AND DATEADD(DAY, -1, check_date)
            GROUP BY dd.FULL_DATE
        )
    )
    SELECT 
        'Conversation Volume' AS metric_name,
        ds.conversations AS current_value,
        hs.avg_conversations AS avg_value,
        hs.std_conversations AS std_dev,
        (ds.conversations - hs.avg_conversations) / NULLIF(hs.std_conversations, 0) AS z_score,
        ABS((ds.conversations - hs.avg_conversations) / NULLIF(hs.std_conversations, 0)) > 2 AS is_anomaly,
        CASE 
            WHEN (ds.conversations - hs.avg_conversations) / NULLIF(hs.std_conversations, 0) > 2 THEN 'SPIKE'
            WHEN (ds.conversations - hs.avg_conversations) / NULLIF(hs.std_conversations, 0) < -2 THEN 'DROP'
            ELSE 'NORMAL'
        END AS anomaly_type
    FROM daily_stats ds, historical_stats hs
    
    UNION ALL
    
    SELECT 
        'Escalation Rate',
        ds.escalation_rate * 100,
        hs.avg_escalation * 100,
        hs.std_escalation * 100,
        (ds.escalation_rate - hs.avg_escalation) / NULLIF(hs.std_escalation, 0),
        ABS((ds.escalation_rate - hs.avg_escalation) / NULLIF(hs.std_escalation, 0)) > 2,
        CASE 
            WHEN (ds.escalation_rate - hs.avg_escalation) / NULLIF(hs.std_escalation, 0) > 2 THEN 'HIGH'
            WHEN (ds.escalation_rate - hs.avg_escalation) / NULLIF(hs.std_escalation, 0) < -2 THEN 'LOW'
            ELSE 'NORMAL'
        END
    FROM daily_stats ds, historical_stats hs
$$;

-- Grant execute permissions
GRANT USAGE ON FUNCTION MODELS.ANALYZE_SENTIMENT(VARCHAR) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.SUMMARIZE_CONVERSATION(VARCHAR) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.EXTRACT_ENTITIES(VARCHAR) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.GET_CHATBOT_KPIS(DATE, DATE) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.GET_ESCALATION_BREAKDOWN(DATE, DATE) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.GET_SERVICE_PERFORMANCE(DATE, DATE) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.GET_CHANNEL_PERFORMANCE(DATE, DATE) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.GET_MEMBER_SEGMENT_ANALYSIS(DATE, DATE) TO ROLE PUBLIC;
GRANT USAGE ON FUNCTION MODELS.DETECT_KPI_ANOMALIES(DATE) TO ROLE PUBLIC;

SELECT 'ML and agent functions created successfully' AS STATUS;
