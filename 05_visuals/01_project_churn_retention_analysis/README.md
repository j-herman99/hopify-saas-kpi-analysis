# 📉 Hopify Churn & Retention Analysis – Visual Assets

This folder contains curated charts and data tables used to analyze customer churn, retention trends, and support-related behavior for the Hopify SaaS business simulation. These visualizations support strategic decisions related to customer success, segmentation, and retention planning.

---

## 🔍 Overview

- **Customer Segments Analyzed**: SMB, Mid-Market, Enterprise  
- **Timeframe**: Multi-year monthly and quarterly views  
- **Metrics Included**: Churn rate (%), retention %, support ticket volume, survival curves  
- **Analysis Techniques**: Cohort analysis, threshold benchmarking, retention decay curves

---

## 📊 Visual Index

| #   | File Name                                                  | Type           | Description                                                                 |
|-----|-------------------------------------------------------------|----------------|-----------------------------------------------------------------------------|
| 01  | `01_hopify_churn_kpi_table.csv`                            | 📄 Table       | KPI summary of churn rate vs benchmark across all customer segments        |
| 02  | `02_hopify_churn_rate_monthly_by_segment.png`              | 📈 Line Chart  | Monthly churn rate trends segmented by SMB, Mid-Market, and Enterprise     |
| 03  | `03_hopify_churn_vs_support_volume_by_segment_static.png` | 📊 Bar Chart   | Static bar chart: churn rate by support ticket volume across segments      |
| 04  | `04_hopify_retention_heatmap_enterprise_full.png`         | 🔥 Heatmap     | Full cohort retention heatmap – Enterprise customers                       |
| 05  | `05_retention_heatmap_midmarket_full.png`                 | 🔥 Heatmap     | Full cohort retention heatmap – Mid-Market customers                       |
| 06  | `06_hopify_retention_heatmap_smb_full.png`                | 🔥 Heatmap     | Full cohort retention heatmap – SMB customers                              |
| 07  | `07_hopify_churn_rate_monthly_by_segment_vs_target.png`   | 📈 Line Chart  | Churn trend vs. segment-specific targets (thresholds)                      |
| 08  | `08_hopify_retained_customers_by_segment_8_cohorts_line.png` | 📉 Line Chart | Retained customers by segment — 8 most recent signup cohorts               |
| 09  | `09_hopify_retained_customers_by_segment_faceted.png`     | 📊 Faceted     | Retained customers over time with one facet per segment                    |
| 10  | `10_hopify_retention_curve_by_segment_8_cohorts_overlay.png` | 📉 Line Chart | Overlay of retention curves by segment for 8 recent cohorts                |
| 11  | `11_hopify_retention_decay_curve_recent_cohorts.png`      | 📉 Line Chart  | Retention decay view for most recent cohorts, with benchmark threshold     |
| 12  | `12_hopify_seg_level_survival_table.csv`                  | 📄 Table       | Raw survival values by segment over months since signup                    |

---

## 📂 Usage Tips

- Pair these visuals with SQL outputs or dashboards for stakeholder presentations.
- Use heatmaps and decay curves to spot retention issues early.
- The CSV files can be used for further statistical analysis or forecasting models.

---

## 🛠️ Tools Used

- Python (`matplotlib`, `seaborn`, `plotly`)
- SQLite (Hopify DB)
- Jupyter Notebook
- Tableau (optional dashboard views)

---

## 📌 Related Projects

- **[Hopify SaaS Database Generator](../04-generate-db-saas-hopify/)**
- **[KPI Analysis SQL Pack](../03_sql/)**  
- **[Executive Summary Decks](../05_visuals/)**

---

> ✅ *Last Updated: July 2025 — Project: Hopify Portfolio / Part 1 – Churn & Retention*