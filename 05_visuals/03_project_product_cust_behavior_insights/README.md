# 🧠 Hopify Product & Customer Behavior – Visual Assets

This folder showcases visual assets supporting behavioral segmentation, product trends, support volume, and customer engagement insights across Hopify's customer base. These visualizations inform decisions on upsell opportunities, product bundling, and customer support optimization.

---

## 🔍 Overview

- **Customer Segments Analyzed**: SMB, Mid-Market, Enterprise  
- **Focus Areas**: Subscription behavior, product analytics, support trends, segmentation  
- **Timeframe**: Multi-quarter rolling view with trend comparisons  
- **Use Cases**: Persona analysis, cross-sell strategies, product planning, CX improvement

---

## 📊 Visual Index

| #   | File Name                                                 | Type         | Description                                                                 |
|-----|------------------------------------------------------------|--------------|-----------------------------------------------------------------------------|
| 01  | `01_hopify_avg_sub_price_v_amt_sub_seg.png`               | 📊 Scatter    | Subscription price vs amount by customer segment                           |
| 02  | `02_hopify_aov_product_seg_plot.png`                      | 📊 Bar        | Average Order Value by Product Segment                                     |
| 03  | `03_hopify_support_v_resolution_seg.png`                  | 📉 Line       | Support tickets vs resolution time by segment                              |
| 04  | `04_hopify_cust_seg_behavior_summ_plots.png`              | 📈 Line       | Overview of customer behavior by segment (engagement + activity)           |
| 05  | `05_hopify_top_2_cross_sell_seg.png`                      | 📊 Bar        | Top 2 cross-sell categories by segment                                     |
| 06  | `06_hopify_avg_subs_rev_seg.png`                          | 📈 Line       | Average subscription revenue per user by segment                           |
| 07  | `07_hopify_prod_aov_by_seg.png`                           | 📊 Bar        | AOV by product category across segments                                    |
| 08  | `08_hopify_seg_behavior_summary.png`                      | 📊 Composite   | Behavior summary matrix (activity, spend, segment behaviors)               |
| 09  | `09_hopify_support_volume_resolution_seg.png`             | 📊 Combo       | Support volume and average resolution time side-by-side                    |
| 10  | `10_hopify_top_10_product_categories.png`                 | 📊 Bar        | Top 10 performing product categories by revenue                            |
| 11  | `11_hopify_top_10_products.png`                           | 📊 Bar        | Top 10 selling individual products across all segments                     |
| 12  | `12_hopify_top_cross_sell_combos_by_segment.png`          | 📊 Stacked     | Most frequent cross-sell combinations, segmented                           |
| 13  | `13_hopify_active_cust_vs_rolling_avg.png`                | 📈 Line        | Active customer counts vs 3-month rolling average                          |

---

## 🧠 Interpretation Tips

- Use cross-sell combo charts to prioritize bundling opportunities by segment.
- Compare support patterns to product and LTV metrics to uncover CX bottlenecks.
- Leverage AOV and subscription revenue trends to improve segmentation logic.

---

## 🛠️ Tools Used

- Python (`pandas`, `seaborn`, `matplotlib`, `plotly`)
- SQLite (Hopify DB)
- Jupyter Notebook + CSV for quick exports

---

## 📌 Related Projects

- **[Churn & Retention Analysis](../01_project_churn_retention_analysis/)**  
- **[Revenue & Profitability Dashboards](../02_project_revenue_profit_analysis/)**  
- **[Hopify Data Generator (Python)](../../02_Documentation/04-generate-db-saas-hopify/)**

---

> ✅ *Last Updated: July 2025 — Project: Hopify Portfolio / Part 3 – Product & Customer Behavior*

---
