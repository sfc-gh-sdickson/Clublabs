-- =============================================
-- Clublabs Intelligence Agent - Synthetic Data
-- Step 3: Generate test data for development
-- =============================================

USE ROLE ACCOUNTADMIN;
USE DATABASE CLUBLABS_INTELLIGENCE;
USE WAREHOUSE CLUBLABS_WH;

-- =============================================
-- POPULATE DIMENSION TABLES
-- =============================================

-- Generate date dimension (2023-2025)
INSERT INTO ANALYTICS.DIM_DATE
SELECT 
    TO_NUMBER(TO_CHAR(DATEADD(DAY, SEQ4(), '2023-01-01'), 'YYYYMMDD')) AS DATE_KEY,
    DATEADD(DAY, SEQ4(), '2023-01-01') AS FULL_DATE,
    DAYOFWEEK(DATEADD(DAY, SEQ4(), '2023-01-01')) AS DAY_OF_WEEK,
    DAYNAME(DATEADD(DAY, SEQ4(), '2023-01-01')) AS DAY_NAME,
    DAY(DATEADD(DAY, SEQ4(), '2023-01-01')) AS DAY_OF_MONTH,
    DAYOFYEAR(DATEADD(DAY, SEQ4(), '2023-01-01')) AS DAY_OF_YEAR,
    WEEKOFYEAR(DATEADD(DAY, SEQ4(), '2023-01-01')) AS WEEK_OF_YEAR,
    MONTH(DATEADD(DAY, SEQ4(), '2023-01-01')) AS MONTH_NUMBER,
    MONTHNAME(DATEADD(DAY, SEQ4(), '2023-01-01')) AS MONTH_NAME,
    QUARTER(DATEADD(DAY, SEQ4(), '2023-01-01')) AS QUARTER,
    YEAR(DATEADD(DAY, SEQ4(), '2023-01-01')) AS YEAR,
    DAYOFWEEK(DATEADD(DAY, SEQ4(), '2023-01-01')) IN (0, 6) AS IS_WEEKEND,
    FALSE AS IS_HOLIDAY
FROM TABLE(GENERATOR(ROWCOUNT => 1096));

-- Populate channel dimension
INSERT INTO ANALYTICS.DIM_CHANNEL (CHANNEL_CODE, CHANNEL_NAME, IS_DIGITAL)
VALUES 
    ('WEB_CHAT', 'Web Chat', TRUE),
    ('MOBILE_APP', 'Mobile App Chat', TRUE),
    ('IVR', 'Interactive Voice Response', FALSE),
    ('PHONE', 'Phone Call', FALSE),
    ('SMS', 'SMS Text', TRUE),
    ('EMAIL', 'Email', TRUE);

-- Populate service type dimension
INSERT INTO ANALYTICS.DIM_SERVICE_TYPE (SERVICE_CODE, SERVICE_NAME, SERVICE_CATEGORY, IS_EMERGENCY, AVERAGE_RESOLUTION_MINUTES)
VALUES 
    ('RSA_TOW', 'Towing Service', 'Roadside Assistance', TRUE, 45),
    ('RSA_FLAT', 'Flat Tire Change', 'Roadside Assistance', TRUE, 30),
    ('RSA_JUMP', 'Battery Jump Start', 'Roadside Assistance', TRUE, 25),
    ('RSA_LOCK', 'Lockout Service', 'Roadside Assistance', TRUE, 35),
    ('RSA_FUEL', 'Fuel Delivery', 'Roadside Assistance', TRUE, 40),
    ('TRV_BOOK', 'Travel Booking', 'Travel Services', FALSE, 20),
    ('TRV_DISC', 'Travel Discounts', 'Travel Services', FALSE, 15),
    ('INS_QUOTE', 'Insurance Quote', 'Insurance', FALSE, 25),
    ('INS_CLAIM', 'Insurance Claim', 'Insurance', FALSE, 60),
    ('MEM_RENEW', 'Membership Renewal', 'Membership', FALSE, 10),
    ('MEM_UPGRADE', 'Membership Upgrade', 'Membership', FALSE, 15),
    ('MEM_CANCEL', 'Membership Cancellation', 'Membership', FALSE, 20),
    ('GEN_INFO', 'General Information', 'General', FALSE, 10),
    ('GEN_FEEDBACK', 'Feedback/Complaint', 'General', FALSE, 30);

-- Populate agent dimension
INSERT INTO ANALYTICS.DIM_AGENT (AGENT_ID, AGENT_TYPE, AGENT_NAME, DEPARTMENT, SKILL_LEVEL)
VALUES 
    ('BOT_ERS_01', 'BOT', 'ERS Virtual Assistant', 'Digital', 'STANDARD'),
    ('BOT_ERS_02', 'BOT', 'ERS Advanced Bot', 'Digital', 'ADVANCED'),
    ('AGENT_001', 'HUMAN', 'Sarah Johnson', 'Roadside Support', 'SENIOR'),
    ('AGENT_002', 'HUMAN', 'Mike Chen', 'Roadside Support', 'STANDARD'),
    ('AGENT_003', 'HUMAN', 'Emily Davis', 'Travel Services', 'SENIOR'),
    ('AGENT_004', 'HUMAN', 'James Wilson', 'Insurance', 'SENIOR'),
    ('AGENT_005', 'HUMAN', 'Lisa Brown', 'Membership', 'STANDARD'),
    ('AGENT_006', 'HUMAN', 'David Lee', 'General Support', 'JUNIOR'),
    ('AGENT_007', 'HUMAN', 'Amanda Garcia', 'Escalation Team', 'EXPERT'),
    ('AGENT_008', 'HUMAN', 'Robert Taylor', 'Escalation Team', 'EXPERT');

-- Generate synthetic members (10,000 members)
INSERT INTO ANALYTICS.DIM_MEMBER (MEMBER_ID, MEMBERSHIP_TYPE, REGION, STATE, JOIN_DATE, TENURE_MONTHS, AGE_GROUP, IS_ACTIVE)
SELECT 
    'MEM_' || LPAD(SEQ4()::VARCHAR, 8, '0') AS MEMBER_ID,
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 'Premier'
        WHEN 1 THEN 'Premier'
        WHEN 2 THEN 'Plus'
        WHEN 3 THEN 'Plus'
        WHEN 4 THEN 'Plus'
        ELSE 'Basic'
    END AS MEMBERSHIP_TYPE,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Northeast'
        WHEN 1 THEN 'Southeast'
        WHEN 2 THEN 'Midwest'
        WHEN 3 THEN 'Southwest'
        ELSE 'West'
    END AS REGION,
    CASE MOD(SEQ4(), 10)
        WHEN 0 THEN 'CA' WHEN 1 THEN 'TX' WHEN 2 THEN 'FL' WHEN 3 THEN 'NY' WHEN 4 THEN 'IL'
        WHEN 5 THEN 'PA' WHEN 6 THEN 'OH' WHEN 7 THEN 'GA' WHEN 8 THEN 'NC' ELSE 'MI'
    END AS STATE,
    DATEADD(DAY, -UNIFORM(30, 3650, RANDOM()), CURRENT_DATE()) AS JOIN_DATE,
    UNIFORM(1, 120, RANDOM()) AS TENURE_MONTHS,
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN '18-25'
        WHEN 1 THEN '26-35'
        WHEN 2 THEN '36-50'
        WHEN 3 THEN '51-65'
        ELSE '65+'
    END AS AGE_GROUP,
    UNIFORM(1, 100, RANDOM()) > 5 AS IS_ACTIVE
FROM TABLE(GENERATOR(ROWCOUNT => 10000));

-- =============================================
-- POPULATE FACT TABLES
-- =============================================

-- Generate synthetic conversations (50,000 conversations over 2 years)
INSERT INTO ANALYTICS.FACT_CONVERSATION (
    CONVERSATION_ID, DATE_KEY, MEMBER_KEY, SERVICE_TYPE_KEY, CHANNEL_KEY,
    INITIAL_AGENT_KEY, FINAL_AGENT_KEY, START_TIMESTAMP, END_TIMESTAMP,
    DURATION_SECONDS, MESSAGE_COUNT, BOT_MESSAGE_COUNT, HUMAN_MESSAGE_COUNT,
    MEMBER_MESSAGE_COUNT, WAS_ESCALATED, ESCALATION_REASON, RESOLUTION_STATUS,
    FIRST_CONTACT_RESOLUTION, SENTIMENT_SCORE, SENTIMENT_LABEL, CSAT_SCORE,
    INTENT_DETECTED, CONFIDENCE_SCORE
)
SELECT 
    'CONV_' || LPAD(SEQ4()::VARCHAR, 10, '0') AS CONVERSATION_ID,
    d.DATE_KEY,
    m.MEMBER_KEY,
    st.SERVICE_TYPE_KEY,
    ch.CHANNEL_KEY,
    1 AS INITIAL_AGENT_KEY,  -- Always starts with bot
    CASE WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN UNIFORM(3, 10, RANDOM()) ELSE 1 END AS FINAL_AGENT_KEY,
    DATEADD(SECOND, UNIFORM(0, 86400, RANDOM()), d.FULL_DATE::TIMESTAMP) AS START_TIMESTAMP,
    DATEADD(SECOND, UNIFORM(0, 86400, RANDOM()) + UNIFORM(60, 3600, RANDOM()), d.FULL_DATE::TIMESTAMP) AS END_TIMESTAMP,
    UNIFORM(60, 3600, RANDOM()) AS DURATION_SECONDS,
    UNIFORM(4, 30, RANDOM()) AS MESSAGE_COUNT,
    UNIFORM(2, 15, RANDOM()) AS BOT_MESSAGE_COUNT,
    CASE WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN UNIFORM(1, 10, RANDOM()) ELSE 0 END AS HUMAN_MESSAGE_COUNT,
    UNIFORM(2, 15, RANDOM()) AS MEMBER_MESSAGE_COUNT,
    UNIFORM(1, 100, RANDOM()) <= 25 AS WAS_ESCALATED,
    CASE WHEN UNIFORM(1, 100, RANDOM()) <= 25 
        THEN CASE MOD(SEQ4(), 5)
            WHEN 0 THEN 'Complex issue requiring human expertise'
            WHEN 1 THEN 'Member requested human agent'
            WHEN 2 THEN 'Bot confidence below threshold'
            WHEN 3 THEN 'Escalation policy triggered'
            ELSE 'Sentiment-based escalation'
        END
        ELSE NULL 
    END AS ESCALATION_REASON,
    CASE UNIFORM(1, 100, RANDOM())
        WHEN 1 THEN 'ABANDONED'
        WHEN 2 THEN 'ABANDONED'
        WHEN 3 THEN 'PENDING'
        ELSE CASE WHEN UNIFORM(1, 100, RANDOM()) <= 25 THEN 'ESCALATED' ELSE 'RESOLVED' END
    END AS RESOLUTION_STATUS,
    UNIFORM(1, 100, RANDOM()) > 30 AS FIRST_CONTACT_RESOLUTION,
    ROUND((UNIFORM(-100, 100, RANDOM())::FLOAT / 100), 2) AS SENTIMENT_SCORE,
    CASE 
        WHEN UNIFORM(-100, 100, RANDOM()) < -30 THEN 'NEGATIVE'
        WHEN UNIFORM(-100, 100, RANDOM()) > 30 THEN 'POSITIVE'
        ELSE 'NEUTRAL'
    END AS SENTIMENT_LABEL,
    UNIFORM(1, 5, RANDOM()) AS CSAT_SCORE,
    st.SERVICE_CODE AS INTENT_DETECTED,
    ROUND((UNIFORM(60, 99, RANDOM())::FLOAT / 100), 2) AS CONFIDENCE_SCORE
FROM TABLE(GENERATOR(ROWCOUNT => 50000)) g
JOIN ANALYTICS.DIM_DATE d ON d.DATE_KEY = TO_NUMBER(TO_CHAR(DATEADD(DAY, UNIFORM(0, 730, RANDOM()), '2023-01-01'), 'YYYYMMDD'))
JOIN ANALYTICS.DIM_MEMBER m ON m.MEMBER_KEY = UNIFORM(1, 10000, RANDOM())
JOIN ANALYTICS.DIM_SERVICE_TYPE st ON st.SERVICE_TYPE_KEY = UNIFORM(1, 14, RANDOM())
JOIN ANALYTICS.DIM_CHANNEL ch ON ch.CHANNEL_KEY = UNIFORM(1, 6, RANDOM());

-- Generate daily KPI aggregates
INSERT INTO ANALYTICS.FACT_DAILY_KPI (
    DATE_KEY, CHANNEL_KEY, SERVICE_TYPE_KEY, TOTAL_CONVERSATIONS, TOTAL_MESSAGES,
    BOT_HANDLED_COUNT, ESCALATED_COUNT, ABANDONED_COUNT, AVG_DURATION_SECONDS,
    AVG_RESPONSE_TIME_SECONDS, AVG_MESSAGE_COUNT, CONTAINMENT_RATE, ESCALATION_RATE,
    ABANDONMENT_RATE, FCR_RATE, AVG_SENTIMENT_SCORE, AVG_CSAT_SCORE,
    POSITIVE_SENTIMENT_COUNT, NEGATIVE_SENTIMENT_COUNT, NEUTRAL_SENTIMENT_COUNT
)
SELECT 
    fc.DATE_KEY,
    fc.CHANNEL_KEY,
    fc.SERVICE_TYPE_KEY,
    COUNT(*) AS TOTAL_CONVERSATIONS,
    SUM(fc.MESSAGE_COUNT) AS TOTAL_MESSAGES,
    SUM(CASE WHEN NOT fc.WAS_ESCALATED THEN 1 ELSE 0 END) AS BOT_HANDLED_COUNT,
    SUM(CASE WHEN fc.WAS_ESCALATED THEN 1 ELSE 0 END) AS ESCALATED_COUNT,
    SUM(CASE WHEN fc.RESOLUTION_STATUS = 'ABANDONED' THEN 1 ELSE 0 END) AS ABANDONED_COUNT,
    AVG(fc.DURATION_SECONDS) AS AVG_DURATION_SECONDS,
    AVG(UNIFORM(5, 60, RANDOM())) AS AVG_RESPONSE_TIME_SECONDS,
    AVG(fc.MESSAGE_COUNT) AS AVG_MESSAGE_COUNT,
    SUM(CASE WHEN NOT fc.WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS CONTAINMENT_RATE,
    SUM(CASE WHEN fc.WAS_ESCALATED THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS ESCALATION_RATE,
    SUM(CASE WHEN fc.RESOLUTION_STATUS = 'ABANDONED' THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS ABANDONMENT_RATE,
    SUM(CASE WHEN fc.FIRST_CONTACT_RESOLUTION THEN 1 ELSE 0 END)::FLOAT / NULLIF(COUNT(*), 0) AS FCR_RATE,
    AVG(fc.SENTIMENT_SCORE) AS AVG_SENTIMENT_SCORE,
    AVG(fc.CSAT_SCORE) AS AVG_CSAT_SCORE,
    SUM(CASE WHEN fc.SENTIMENT_LABEL = 'POSITIVE' THEN 1 ELSE 0 END) AS POSITIVE_SENTIMENT_COUNT,
    SUM(CASE WHEN fc.SENTIMENT_LABEL = 'NEGATIVE' THEN 1 ELSE 0 END) AS NEGATIVE_SENTIMENT_COUNT,
    SUM(CASE WHEN fc.SENTIMENT_LABEL = 'NEUTRAL' THEN 1 ELSE 0 END) AS NEUTRAL_SENTIMENT_COUNT
FROM ANALYTICS.FACT_CONVERSATION fc
GROUP BY fc.DATE_KEY, fc.CHANNEL_KEY, fc.SERVICE_TYPE_KEY;

-- Generate conversation transcripts for Cortex Search
INSERT INTO RAW.CONVERSATION_TRANSCRIPTS (
    TRANSCRIPT_ID, CONVERSATION_ID, MEMBER_ID, FULL_TRANSCRIPT, TRANSCRIPT_SUMMARY,
    KEY_TOPICS, SERVICE_CATEGORY, RESOLUTION_NOTES, CONVERSATION_DATE
)
SELECT 
    'TR_' || fc.CONVERSATION_ID AS TRANSCRIPT_ID,
    fc.CONVERSATION_ID,
    dm.MEMBER_ID,
    CASE st.SERVICE_CATEGORY
        WHEN 'Roadside Assistance' THEN 
            'Member: Hi, I need help. My car broke down.\n' ||
            'Bot: I''m sorry to hear that. I can help you request roadside assistance. Can you confirm your location?\n' ||
            'Member: I''m at ' || UNIFORM(100, 9999, RANDOM())::VARCHAR || ' Main Street.\n' ||
            'Bot: Thank you. I''ve located your membership and am dispatching help. A ' || st.SERVICE_NAME || ' service provider will arrive in approximately ' || st.AVERAGE_RESOLUTION_MINUTES || ' minutes.\n' ||
            'Member: Thank you so much!\n' ||
            'Bot: You''re welcome. Is there anything else I can help you with today?'
        WHEN 'Travel Services' THEN
            'Member: I want to book a hotel for my trip.\n' ||
            'Bot: I''d be happy to help you with travel bookings. Where are you planning to travel and what dates?\n' ||
            'Member: I''m going to Orlando next month for a week.\n' ||
            'Bot: Great choice! As a ' || dm.MEMBERSHIP_TYPE || ' member, you qualify for exclusive discounts. Let me show you available options.\n' ||
            'Member: That sounds perfect.\n' ||
            'Bot: I found several hotels with member discounts ranging from 15-25% off. Would you like me to share the details?'
        WHEN 'Insurance' THEN
            'Member: I need to file an insurance claim.\n' ||
            'Bot: I can help you with your insurance claim. Can you tell me more about what happened?\n' ||
            'Member: I was in a minor accident yesterday.\n' ||
            'Bot: I''m sorry to hear that. Let me gather some information to start your claim. Was anyone injured?\n' ||
            'Member: No injuries, just vehicle damage.\n' ||
            'Bot: That''s good to hear. I''ll connect you with our claims specialist to complete the process.'
        ELSE
            'Member: I have a question about my membership.\n' ||
            'Bot: Of course! I''m here to help with any membership questions. What would you like to know?\n' ||
            'Member: When does my membership expire?\n' ||
            'Bot: Let me check your account. Your ' || dm.MEMBERSHIP_TYPE || ' membership is active and set to renew on ' || DATEADD(MONTH, UNIFORM(1, 12, RANDOM()), CURRENT_DATE())::VARCHAR || '.\n' ||
            'Member: Can I upgrade my membership?\n' ||
            'Bot: Absolutely! I can help you explore upgrade options that provide additional benefits.'
    END AS FULL_TRANSCRIPT,
    'Member contacted support regarding ' || st.SERVICE_NAME || '. Issue was ' || 
    CASE fc.RESOLUTION_STATUS 
        WHEN 'RESOLVED' THEN 'successfully resolved'
        WHEN 'ESCALATED' THEN 'escalated to human agent'
        ELSE 'not fully resolved'
    END || '.' AS TRANSCRIPT_SUMMARY,
    ARRAY_CONSTRUCT(st.SERVICE_CATEGORY, st.SERVICE_NAME, dm.MEMBERSHIP_TYPE) AS KEY_TOPICS,
    st.SERVICE_CATEGORY,
    CASE fc.RESOLUTION_STATUS 
        WHEN 'RESOLVED' THEN 'Issue resolved successfully via chatbot'
        WHEN 'ESCALATED' THEN 'Escalated to human agent: ' || COALESCE(fc.ESCALATION_REASON, 'Standard escalation')
        ELSE 'Follow-up required'
    END AS RESOLUTION_NOTES,
    dd.FULL_DATE AS CONVERSATION_DATE
FROM ANALYTICS.FACT_CONVERSATION fc
JOIN ANALYTICS.DIM_MEMBER dm ON fc.MEMBER_KEY = dm.MEMBER_KEY
JOIN ANALYTICS.DIM_SERVICE_TYPE st ON fc.SERVICE_TYPE_KEY = st.SERVICE_TYPE_KEY
JOIN ANALYTICS.DIM_DATE dd ON fc.DATE_KEY = dd.DATE_KEY
WHERE fc.CONVERSATION_KEY <= 10000;  -- Generate 10k transcripts for search

SELECT 'Synthetic data generation complete' AS STATUS;
SELECT 'Members: ' || COUNT(*) FROM ANALYTICS.DIM_MEMBER;
SELECT 'Conversations: ' || COUNT(*) FROM ANALYTICS.FACT_CONVERSATION;
SELECT 'Transcripts: ' || COUNT(*) FROM RAW.CONVERSATION_TRANSCRIPTS;
