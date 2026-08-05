-- Session-level e-commerce funnel from GA4 BigQuery export
-- Dataset: bigquery-public-data.ga4_obfuscated_sample_ecommerce (Nov 2020 - Jan 2021)
-- Funnel: session -> view_item -> add_to_cart -> begin_checkout -> purchase

WITH sessions AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS session_date,
    ANY_VALUE(CONCAT(traffic_source.source, ' / ', traffic_source.medium)) AS channel,
    ANY_VALUE(device.category) AS device_category,
    COUNTIF(event_name = 'view_item') > 0 AS viewed_item,
    COUNTIF(event_name = 'add_to_cart') > 0 AS added_to_cart,
    COUNTIF(event_name = 'begin_checkout') > 0 AS began_checkout,
    COUNTIF(event_name = 'purchase') > 0 AS purchased
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id, session_id
)

SELECT
  session_date,
  channel,
  device_category,
  COUNT(*) AS sessions,
  COUNTIF(viewed_item) AS sessions_view_item,
  COUNTIF(added_to_cart) AS sessions_add_to_cart,
  COUNTIF(began_checkout) AS sessions_begin_checkout,
  COUNTIF(purchased) AS sessions_purchase,
  SAFE_DIVIDE(COUNTIF(added_to_cart), COUNTIF(viewed_item)) AS view_to_cart_rate,
  SAFE_DIVIDE(COUNTIF(began_checkout), COUNTIF(added_to_cart)) AS cart_to_checkout_rate,
  SAFE_DIVIDE(COUNTIF(purchased), COUNTIF(began_checkout)) AS checkout_to_purchase_rate,
  SAFE_DIVIDE(COUNTIF(purchased), COUNT(*)) AS session_conversion_rate
FROM sessions
WHERE session_id IS NOT NULL
GROUP BY session_date, channel, device_category
