# Executive Brief: E-Commerce Growth Diagnostic

*Prepared as a client-style readout. Figures are drawn from the queries in `sql/`;
fill in the values from your own run before presenting this to anyone.*

## Situation

The store converts sessions into revenue at a rate typical for mid-market e-commerce,
but growth is being constrained at two specific points rather than across the funnel
generally. Top-of-funnel volume is not the binding constraint.

## Three findings

**1. Checkout friction is device-specific, not universal.**
View-to-cart rates are comparable across devices. The divergence appears between cart
and checkout, where mobile underperforms desktop. This localizes the problem to the
checkout experience rather than to product discovery or pricing.

**2. Discovery is concentrated on a narrow head of the catalogue.**
A small share of items absorbs most product views, and long-tail items convert at a
different rate per view than head items once they are seen. The constraint on tail
revenue is exposure, not desirability.

**3. Traffic share and revenue share are misaligned across channels.**
Several channels take a materially larger share of sessions than of revenue, and at
least one shows the reverse. Repeat-purchase rates differ by acquisition channel, so
channels ranked on first-purchase conversion alone are ranked wrongly.

## Recommendations, in priority order

| # | Action | Rationale | How to validate |
|---|--------|-----------|-----------------|
| 1 | Reduce mobile checkout friction (payment options, form length, guest checkout) | Largest single leak, narrowly localized | User-level A/B test powered on cart-to-checkout |
| 2 | Increase long-tail exposure through recommendation placement | Tail revenue is exposure-constrained | A/B test on the placement, primary metric: tail item purchases |
| 3 | Rebalance acquisition spend toward channels with positive value gap and higher repeat rates | Spend is following volume, not value | Matched-market geo split, difference in differences |

## What I would need before committing to numbers

Cost data by channel. Everything above is revenue-side only; without spend, "reallocate
budget" is directionally sound but not sized. With cost data the same model yields
marginal return by channel and a defensible reallocation amount.

## Caveats

Observational data, holiday-season window, user-scoped attribution. See
`METHODOLOGY.md`. No recommendation here should be scaled without the validation
design listed against it.
