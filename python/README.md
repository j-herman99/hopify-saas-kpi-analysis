# 🐍 Hopify KPI Visual Scripts

This folder contains Python scripts used to visualize and support the Hopify SaaS KPI and churn analysis project. Each script produces presentation-ready visuals or flowcharts tied to specific business scenarios.

---

## 📜 Script Index

| Script | Purpose |
|--------|---------|
| `hopify_churn_query_flow_v1.py` | Visual flowchart showing SQL logic structure for churn analysis |
| `hopify_churn_rate_by_segment.py` | Line or bar chart of monthly churn rate segmented by SMB, Mid-Market, and Enterprise |
| `hopify_cohort_ret_curve_decay_visual.py` | Retention decay visualization for customer cohorts over time |
| `hopify_ret_funnel_flowchart` | Graphviz flow showing marketing funnel: traffic → leads → MQLs → conversions |
| `hopify_lifecycle_flowchart.py` | End-to-end customer lifecycle: signup → usage → retention/churn flow |

---

## 🧪 Experimental Scripts

Scripts under `/python/sandbox/` are exploratory or under development. Final versions may be promoted to this folder.

---

## 🖼 Output Directory

Most visuals are saved to `/visuals/` and referenced in reports or the main `README.md`.

---

## 🛠 Requirements

Install dependencies using:

```bash
pip install graphviz matplotlib seaborn
```

Graphviz must also be installed separately via Homebrew, Chocolatey, or from https://graphviz.org/download/

---