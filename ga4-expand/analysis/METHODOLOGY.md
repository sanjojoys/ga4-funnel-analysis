# Methodology and Measurement Design

This project is a diagnostic, not a causal study. Everything below is written to make
that distinction explicit, and to state how each recommendation would be validated
before a client spent money on it.

## What observational GA4 data can and cannot tell you

It can tell you: where sessions leak out of the funnel, which segments behave
differently, which channels correlate with higher revenue per session, and which parts
of the catalogue get starved of discovery.

It cannot tell you: whether a channel *caused* the revenue attributed to it, or what
would have happened without a given campaign. Channel figures here reflect correlation
with acquisition source, and the export's `traffic_source` is user-scoped (first touch),
which predates session-scoped `collected_traffic_source`. Anyone presenting these
numbers as incremental impact is overclaiming.

## How each recommendation would be validated

**1. Randomized A/B test (default for on-site changes)**
For the mobile-checkout and long-tail-discovery recommendations, the cleanest read is a
user-level randomized split. Design points that matter: randomize at the user level, not
session level, or returning users cross conditions; power the test on the *funnel step
being changed* (cart-to-checkout), not on the downstream revenue metric, which is noisier
and needs far more traffic; pre-register the primary metric to avoid reading whichever
number moved.

**2. Holdout group (for always-on programmes)**
Where a change cannot be toggled per user, hold out a random share of eligible users and
measure the delta in conversion between exposed and held-out groups. The holdout must be
carved before exposure begins, and it must be large enough to detect the minimum effect
worth acting on. Reporting a holdout result without a pre-computed minimum detectable
effect is how teams talk themselves into noise.

**3. Geo split (for spend changes)**
Budget reallocation cannot be A/B tested per user, because spend is bought at market
level. Matched-market geo design: pair regions on pre-period trend, raise spend in one
half, hold the other flat, and read the difference in difference. Watch for spillover
between adjacent markets and for pre-period trends that were not actually parallel.

**4. Pre/post with control (last resort)**
Usable when neither randomization nor geo split is possible, for example a site-wide
feature launch. Requires a control series that is plausibly subject to the same seasonality
(a comparable device segment, or an unaffected market). Weakest of the four designs, and
should be labelled as such when presented.

## Known threats to validity in this dataset

- **Seasonality.** The window spans Black Friday and the December holiday peak. Any
  period-over-period comparison inside this range is confounded by seasonal demand.
- **Obfuscation.** Google obfuscates and samples this public export; absolute revenue
  figures are illustrative, ratios are more trustworthy than levels.
- **Bot and internal traffic.** Not filtered in the raw export.
- **Selection in the long-tail cut.** Items are classified by realized purchase volume,
  so the segment definition is partly downstream of the outcome being measured. A
  cleaner design would classify on a prior period and measure on a later one.

## Why this section exists

In a consulting context the analysis is the easy half. The half that determines whether a
client acts on it is being explicit about what the data supports, what it does not, and
what test would settle the question. That is the standard applied here.
