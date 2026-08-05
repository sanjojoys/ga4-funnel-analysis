-- Budget reallocation model: where should the next unit of acquisition spend go?
-- Business question: given finite acquisition budget, which channels are under- or
-- over-funded relative to the value of the users they bring?
--
-- Method: rank channels on revenue per session and on repeat-purchase propensity,
-- then compare each channel's share of sessions against its share of revenue.
-- A channel taking a larger share of traffic than of revenue is a reallocation
-- candidate. This is a diagnostic, not a causal claim: see analysis/METHODOLOGY.md
-- for how the recommendation would be validated before scaling.

WITH session_facts AS (
  SELECT
    user_pseudo_id,
    (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id') AS session_id,
    ANY_VALUE(CONCAT(traffic_source.source, ' / ', traffic_source.medium)) AS channel,
    COUNTIF(event_name = 'purchase') > 0 AS converted,
    SUM(IF(event_name = 'purchase', ecommerce.purchase_revenue_in_usd, 0)) AS session_revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
  GROUP BY user_pseudo_id, session_id
),

repeat_behaviour AS (
  SELECT
    user_pseudo_id,
    COUNTIF(converted) AS converting_sessions
  FROM session_facts
  GROUP BY user_pseudo_id
),

channel_agg AS (
  SELECT
    s.channel,
    COUNT(*) AS sessions,
    COUNT(DISTINCT s.user_pseudo_id) AS users,
    COUNTIF(s.converted) AS converting_sessions,
    SUM(s.session_revenue) AS revenue,
    COUNT(DISTINCT IF(r.converting_sessions > 1, s.user_pseudo_id, NULL)) AS repeat_buyers
  FROM session_facts s
  JOIN repeat_behaviour r USING (user_pseudo_id)
  WHERE s.session_id IS NOT NULL
  GROUP BY s.channel
  HAVING COUNT(*) >= 500
)

SELECT
  channel,
  sessions,
  users,
  ROUND(revenue, 2) AS revenue_usd,
  ROUND(SAFE_DIVIDE(revenue, sessions), 4) AS revenue_per_session,
  SAFE_DIVIDE(converting_sessions, sessions) AS conversion_rate,
  SAFE_DIVIDE(repeat_buyers, users) AS repeat_buyer_rate,
  ROUND(SAFE_DIVIDE(sessions, SUM(sessions) OVER ()), 4) AS share_of_sessions,
  ROUND(SAFE_DIVIDE(revenue, SUM(revenue) OVER ()), 4) AS share_of_revenue,
  ROUND(SAFE_DIVIDE(revenue, SUM(revenue) OVER ()) - SAFE_DIVIDE(sessions, SUM(sessions) OVER ()), 4) AS value_gap,
  CASE
    WHEN SAFE_DIVIDE(revenue, SUM(revenue) OVER ()) - SAFE_DIVIDE(sessions, SUM(sessions) OVER ()) > 0.02
      THEN 'Underfunded: candidate for increased investment'
    WHEN SAFE_DIVIDE(revenue, SUM(revenue) OVER ()) - SAFE_DIVIDE(sessions, SUM(sessions) OVER ()) < -0.02
      THEN 'Overfunded: candidate for reallocation'
    ELSE 'Balanced'
  END AS reallocation_signal
FROM channel_agg
ORDER BY value_gap DESC
