# 💰 Hopify Revenue & Profitability Analysis – Visual Assets

This folder contains curated charts and summary visuals that explore Hopify’s financial performance across customer segments. These visualizations support strategic insights around revenue growth, ARPU trends, retention-based profitability, and customer lifetime value.

---

## 🔍 Overview

- **Customer Segments Analyzed**: SMB, Mid-Market, Enterprise  
- **Timeframe**: Fiscal quarters (multi-year)  
- **Metrics Included**: ARPU, MRR, expansion revenue, NRR, GRR, LTV, CAC Payback  
- **Analysis Techniques**: Benchmark comparison, target variance analysis, profitability stacking

---

## 📊 Visual Index

| #   | File Name                                           | Type          | Description                                                                 |
|-----|----------------------------------------------------|---------------|-----------------------------------------------------------------------------|
| 01  | `01_hopify_arpu_time_seg.png`                      | 📈 Line Chart  | ARPU trend over time by segment with labeled values                         |
| 02  | `02_hopify_expansion_rev_over_time_seg.png`        | 📈 Line Chart  | Expansion revenue growth across segments with confidence intervals          |
| 03  | `03_hopify_mrr_v_target_seg_over_time.png`         | 📈 Line Chart  | Monthly Recurring Revenue vs target by segment (wide aspect)               |
| 04  | `03_hopify_mrr_vs_target_seg.png`                  | 📈 Line Chart  | MRR vs target by segment (portrait layout version)                          |
| 05  | `04_hopify_nrr_grr_time_seg.png`                   | 📉 Line Chart  | NRR and GRR over time with segment-specific benchmarks                      |
| 06  | `05_hopify_cac_payback_seg_pivot.png`              | 📊 Bar Chart   | CAC Payback Period by Segment (in days)                                     |
| 07  | `06_hopify_cust_ltv_summary.png`                   | 📊 Bar Chart   | Estimated Customer Lifetime Value (LTV) vs benchmark targets                |
| 08  | `07_hopify_est_ltv_v_target_seg_summ.png`          | 📊 Bar Chart   | Side-by-side comparison of actual vs target LTV values                      |
| 09  | `08_hopify_ltv_vs_target_by_segment.png`           | 📊 Bar Chart   | Lifetime Value by Segment – labeled bars with benchmarks                    |
| 10  | `09_hopify_ltv_vs_target_seg.png`                  | 📊 Bar Chart   | Stacked LTV comparison across segments with benchmark overlay               |

---

## 📂 Usage Tips

- Compare actual KPIs against target lines to identify lagging segments.
- Use MRR and ARPU plots to assess revenue momentum and seasonal shifts.
- LTV and CAC Payback visuals help evaluate long-term customer profitability.

---

## 🛠️ Tools Used

- Python (`matplotlib`, `seaborn`, `plotly`)
- SQLite (Hopify DB)
- Jupyter Notebook
- Excel (for light post-processing and benchmarking)

---

## 📌 Related Projects

- **[Hopify SaaS Database Generator](../04-generate-db-saas-hopify/)**  
- **[KPI Analysis SQL Pack](../03_sql/)**  
- **[Executive Summary Decks](../05_visuals/)**

---

> ✅ *Last Updated: July 2025 — Project: Hopify Portfolio / Part 2 – Revenue & Profitability*