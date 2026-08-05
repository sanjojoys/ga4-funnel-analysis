# E-Commerce Growth Diagnostic: GA4 + BigQuery + Looker Studio

An analytics-consulting style engagement built on raw GA4 event data: funnel diagnosis,
cohort retention, catalogue analysis, and a channel budget reallocation model, with an
executive brief and an explicit measurement-design section.

**Live dashboard:** [ADD LOOKER STUDIO LINK HERE]
**Executive brief:** [analysis/EXECUTIVE_BRIEF.md](analysis/EXECUTIVE_BRIEF.md)
**Measurement design:** [analysis/METHODOLOGY.md](analysis/METHODOLOGY.md)

## Data

`bigquery-public-data.ga4_obfuscated_sample_ecommerce` - the Google Merchandise Store
GA4 export, roughly 4M+ events across ~270k users, Nov 2020 to Jan 2021. Analysis is
built on the raw event stream rather than pre-aggregated GA4 reports.

## Analyses

| Query | Question it answers |
|-------|--------------------|
| `01_session_funnel.sql` | Where do sessions leak between view, cart, checkout, and purchase? |
| `02_channel_performance.sql` | Which channels deliver revenue per session, not just traffic? |
| `03_daily_kpis.sql` | How do sessions, conversion, and AOV trend over the period? |
| `04_cohort_retention.sql` | Which channels acquire users who return and buy again? |
| `05_longtail_vs_head.sql` | Is tail revenue constrained by demand or by exposure? |
| `06_budget_reallocation.sql` | Which channels are over- or under-funded relative to the value they deliver? |

Each runs as a custom query against the BigQuery connector in Looker Studio.

## What this project is trying to demonstrate

Not pipeline engineering. The point is the consulting chain: diagnose a business
constraint from event-level data, quantify it, recommend an action, and state the
experiment that would prove the recommendation before a client funds it. The
methodology document is deliberately as detailed as the SQL.

## Author

Sanjo Joy - [linkedin.com/in/sanjojoy](https://linkedin.com/in/sanjojoy)
