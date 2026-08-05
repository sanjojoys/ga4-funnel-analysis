-- Head vs long-tail catalogue performance
-- Business question: does discovery friction differ between top-selling items and the
-- long tail? This is the analysis that justifies a recommendation-carousel style
-- intervention, and it is where placement subsidy money usually earns or wastes its keep.

WITH item_events AS (
  SELECT
    items.item_id,
    ANY_VALUE(items.item_name) AS item_name,
    COUNTIF(event_name = 'view_item') AS views,
    COUNTIF(event_name = 'add_to_cart') AS add_to_carts,
    COUNTIF(event_name = 'purchase') AS purchases,
    SUM(IF(event_name = 'purchase', items.item_revenue_in_usd, 0)) AS revenue
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
  UNNEST(items) AS items
  WHERE _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND items.item_id IS NOT NULL
  GROUP BY items.item_id
),

ranked AS (
  SELECT
    *,
    SUM(purchases) OVER () AS total_purchases,
    SUM(purchases) OVER (ORDER BY purchases DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_purchases
  FROM item_events
),

classified AS (
  SELECT
    *,
    CASE
      WHEN SAFE_DIVIDE(cumulative_purchases, total_purchases) <= 0.5 THEN 'Head (top 50% of volume)'
      WHEN SAFE_DIVIDE(cumulative_purchases, total_purchases) <= 0.8 THEN 'Mid tail'
      ELSE 'Long tail'
    END AS catalogue_segment
  FROM ranked
)

SELECT
  catalogue_segment,
  COUNT(*) AS distinct_items,
  SUM(views) AS views,
  SUM(add_to_carts) AS add_to_carts,
  SUM(purchases) AS purchases,
  ROUND(SUM(revenue), 2) AS revenue_usd,
  SAFE_DIVIDE(SUM(add_to_carts), SUM(views)) AS view_to_cart_rate,
  SAFE_DIVIDE(SUM(purchases), SUM(views)) AS view_to_purchase_rate,
  ROUND(SAFE_DIVIDE(SUM(views), COUNT(*)), 1) AS avg_views_per_item
FROM classified
GROUP BY catalogue_segment
ORDER BY revenue_usd DESC
