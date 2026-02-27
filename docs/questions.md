# Test Questions for Clublabs Intelligence Agent

Use these questions to validate agent functionality across all tools.

---

## Category 1: KPI Queries (Cortex Analyst)

### Basic Metrics
1. What is the current containment rate?
2. Show me the escalation rate for the past month
3. What's our average CSAT score?
4. How many conversations did we handle last week?
5. What's the average conversation duration?

### Trends
6. How has containment rate changed over the past 30 days?
7. Compare this month's CSAT to last month
8. Show me weekly conversation volumes for the past quarter
9. What's the trend in average sentiment over time?
10. Are escalation rates improving or declining?

### Comparisons
11. Which channel has the highest containment rate?
12. Compare CSAT scores across different service categories
13. How do Premier members compare to Basic members in satisfaction?
14. Which region has the most escalations?
15. What's the performance difference between weekdays and weekends?

---

## Category 2: Transcript Search (Cortex Search)

### Issue Discovery
16. Find conversations where members complained about wait times
17. Search for discussions about towing delays
18. Show me conversations involving battery jump issues
19. Find examples of frustrated members
20. Search for conversations mentioning "manager" or "supervisor"

### Pattern Identification
21. Find conversations that were successfully resolved by the bot
22. Search for examples of high-satisfaction interactions
23. Find conversations about membership renewal
24. Show me transcripts involving insurance claims
25. Find conversations from Premier members

---

## Category 3: Service Analysis (SQL Functions)

### Service Performance
26. Which service types have the highest escalation rates?
27. What's the average handle time for roadside assistance requests?
28. Compare containment rates across all service categories
29. Which emergency services have the best CSAT scores?
30. Show me the breakdown of requests by service type

### Channel Analysis
31. Give me a performance summary by channel
32. Which digital channels perform best?
33. How does mobile app compare to web chat?
34. What percentage of conversations come from each channel?
35. Which channel has the fastest resolution times?

---

## Category 4: Member Insights

### Segmentation
36. How do different membership tiers compare in engagement?
37. Which age group uses the chatbot most frequently?
38. What regions have the lowest satisfaction scores?
39. How does tenure affect escalation likelihood?
40. Compare engagement patterns across membership types

### Behavior Analysis
41. What percentage of members are repeat users?
42. How many interactions does the average member have per month?
43. Which members have the most escalations?
44. What services do Premier members use most?
45. Are newer members more likely to escalate?

---

## Category 5: Anomaly Detection

46. Were there any anomalies in yesterday's metrics?
47. Detect unusual patterns in escalation rate this week
48. Are there any spikes in conversation volume?
49. Flag any days with abnormal CSAT scores
50. Check for sentiment anomalies in the past 7 days

---

## Category 6: Complex Multi-Tool Queries

51. What caused the spike in escalations last Tuesday, and can you show me example conversations?
52. Which service categories are underperforming, and what are members saying about them?
53. Compare this week's KPIs to last week, and identify any concerning trends
54. Find the top reasons members are dissatisfied and suggest improvements
55. Give me an executive summary of chatbot performance for the monthly report

---

## Category 7: Time-Based Analysis

56. Show me hourly conversation patterns for last Monday
57. What time of day has the highest escalation rate?
58. Compare morning vs afternoon performance
59. Which days of the week are busiest?
60. How did performance change quarter over quarter?

---

## Expected Response Types

| Question Category | Primary Tool | Expected Response |
|------------------|--------------|-------------------|
| KPI Queries | Cortex Analyst | SQL results + explanation |
| Transcript Search | Cortex Search | Relevant transcripts |
| Service Analysis | SQL Functions | Tabular data |
| Member Insights | Cortex Analyst | Segmented analysis |
| Anomaly Detection | SQL Functions | Anomaly flags + details |
| Complex Queries | Multiple Tools | Synthesized insights |

---

## Validation Checklist

- [ ] Agent responds to natural language queries
- [ ] Cortex Analyst generates accurate SQL
- [ ] Search returns relevant transcripts
- [ ] SQL functions return expected data formats
- [ ] Multi-tool queries synthesize information correctly
- [ ] Response times are acceptable (<30 seconds)
- [ ] Error handling provides helpful feedback
