# ❓ FAQ – Hopify KPI Modeling

## Why does churn sometimes appear higher than expected in SMB?
SMB customers have higher support volume and lower retention benchmarks. The model includes:
- Support friction → higher churn probability
- Shorter average subscription lifespans
- Price sensitivity in subscription tiering

## Why is ARPU tracked separately by segment?
Segment-level revenue is skewed by pricing tiers. Benchmark comparisons and profitability decisions require isolating:
- Plan prices by segment
- Order behavior by customer type

## How are NRR / GRR calculated?
NRR = (Revenue from current cohort this month including expansions) / (Revenue from same cohort prior month)  
GRR excludes expansions and upgrades.

## Why use both Graphviz and DBeaver for ERDs?
- Graphviz = programmatic, portable
- DBeaver = human-readable, ideal for slide decks