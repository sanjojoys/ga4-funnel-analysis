# GA4 E-Commerce Funnel & Channel Analysis (BigQuery + Looker Studio)

Session-level funnel and channel performance analysis built directly on the raw GA4
BigQuery event export, visualized in an interactive Looker Studio dashboard.

**Live dashboard:** [ADD LOOKER STUDIO LINK HERE]

## What this shows

- Rebuilding sessions and a purchase funnel (view_item -> add_to_cart -> begin_checkout -> purchase)
  from raw GA4 event data with SQL, not from pre-aggregated GA4 reports
- Channel performance: sessions, conversion rate, revenue, and revenue per session by source/medium
- Daily KPI trends: sessions, users, conversion rate, revenue, average order value

Data: `bigquery-public-data.ga4_obfuscated_sample_ecommerce` (Google Merchandise Store,
Nov 2020 - Jan 2021, obfuscated public sample).

## Structure

```
sql/
  01_session_funnel.sql        Funnel stages by date, channel, device
  02_channel_performance.sql   Channel-level conversion and revenue metrics
  03_daily_kpis.sql            Daily trend KPIs
```

Each query is used as a custom query in Looker Studio's BigQuery connector, so the
dashboard reads straight from the event-level export.

## Example insight

Mobile sessions show a materially weaker cart-to-checkout rate than desktop across most
channels in this period, while view-to-cart rates are comparable. If this were a client
engagement, the recommendation would be to prioritize mobile checkout friction (payment
options, form length) over top-of-funnel spend, and to validate any fix with a holdout
or pre/post design with a control before scaling it.

## Known limitations (deliberate)

- `traffic_source` in the GA4 export is user-scoped (first touch). Session-scoped
  attribution would use `collected_traffic_source`, which this 2020 sample predates.
  Channel figures therefore reflect acquisition source, not per-session source.
- The sample is obfuscated and truncated by Google; absolute figures are illustrative.

## Author

Sanjo Joy - [linkedin.com/in/sanjojoy](https://linkedin.com/in/sanjojoy)
