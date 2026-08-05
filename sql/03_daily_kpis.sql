-- Daily KPI trend: sessions, users, conversion rate, revenue, AOV
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Nov 2020 - Jan 2021)

WITH session_facts AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS session_date,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue_in_usd, 0)) AS session_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id, session_id
)

SELECT
  session_date,
  COUNT(*) AS sessions,
  COUNT(DISTINCT user_pseudo_id) AS users,
  SUM(purchases) AS purchases,
  SAFE_DIVIDE(COUNTIF(purchases > 0), COUNT(*)) AS session_conversion_rate,
  ROUND(SUM(session_revenue), 2) AS revenue_usd,
  ROUND(SAFE_DIVIDE(SUM(session_revenue), NULLIF(SUM(purchases), 0)), 2) AS avg_order_value
FROM session_facts
WHERE session_id IS NOT NULL
GROUP BY session_date
ORDER BY session_date
