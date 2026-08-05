-- Weekly acquisition cohorts and repeat-purchase behaviour
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce
-- Business question: which acquisition channels bring users who come back and buy again,
-- not just users who convert once?

WITH first_seen AS (
  SELECT
    user_pseudo_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS first_date,
    ANY_VALUE(CONCAT(traffic_source.source, ' / ', traffic_source.medium)) AS acq_channel
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id
),

activity AS (
  SELECT
    user_pseudo_id,
    PARSE_DATE('%Y%m%d', event_date) AS activity_date,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue_in_usd, 0)) AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id, activity_date
)

SELECT
  DATE_TRUNC(f.first_date, WEEK(MONDAY)) AS cohort_week,
  f.acq_channel,
  DATE_DIFF(a.activity_date, f.first_date, WEEK) AS weeks_since_acquisition,
  COUNT(DISTINCT f.user_pseudo_id) AS active_users,
  COUNT(DISTINCT IF(a.purchases > 0, f.user_pseudo_id, NULL)) AS purchasing_users,
  ROUND(SUM(a.revenue), 2) AS revenue_usd
FROM first_seen f
JOIN activity a USING (user_pseudo_id)
GROUP BY cohort_week, acq_channel, weeks_since_acquisition
ORDER BY cohort_week, acq_channel, weeks_since_acquisition
