-- Channel performance: sessions, conversion rate, revenue, revenue per session
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Nov 2020 - Jan 2021)
-- Note: traffic_source in the GA4 export is user-scoped (first touch). Session-scoped
-- attribution would use collected_traffic_source (not present in this 2020 sample).
-- This is a known and deliberate simplification; see README.

WITH session_facts AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS session_date,
    ANY_VALUE(CONCAT(traffic_source.source, ' / ', traffic_source.medium)) AS channel,
    COUNTIF(event_name = 'purchase') > 0 AS converted,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue_in_usd, 0)) AS session_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id, session_id
)

SELECT
  session_date,
  channel,
  COUNT(*) AS sessions,
  COUNTIF(converted) AS converting_sessions,
  SAFE_DIVIDE(COUNTIF(converted), COUNT(*)) AS conversion_rate,
  ROUND(SUM(session_revenue), 2) AS revenue_usd,
  ROUND(SAFE_DIVIDE(SUM(session_revenue), COUNT(*)), 4) AS revenue_per_session
FROM session_facts
WHERE session_id IS NOT NULL
GROUP BY session_date, channel
