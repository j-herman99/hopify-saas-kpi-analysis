# ✅ Hopify KPI Analysis – Scenario Index (Grouped by Project)

This index maps all SQL scenario files to their associated project and business objective.

---

## 📁 01_Project_Churn_Retention_Analysis

| Scenario | File Name                                 | Key Focus |
|----------|--------------------------------------------|-----------|
| 1        | `01_hopify_churn_analysis.sql`             | Monthly churn, segment churn, retention vs. benchmarks |
| 2        | `03_hopify_cohort_retention_analysis.sql`  | Cohort retention rates and decay patterns |
| 3        | `06_hopify_stickets_vs_churn.sql`          | Support ticket volume and resolution impact on churn |

---

## 📁 02_Project_Revenue_Profit_Analysis

| Scenario | File Name                                 | Key Focus |
|----------|--------------------------------------------|-----------|
| 4        | `02_hopify_revenue_analysis.sql`           | Revenue trends, payments, order-level revenue |
| 5        | `07_hopify_nrr_grr_analysis.sql`           | Net Revenue Retention (NRR) and Gross RR by segment |
| 6        | `09_hopify_expansion_rev_analysis.sql`     | Expansion vs net new revenue |
| 7        | `10_hopify_ltv_segment_analysis.sql`       | Lifetime Value (LTV) by segment |
| 8        | `12_hopify_avg_rev_user_analysis.sql`      | ARPU by segment and month |

---

## 📁 03_Project_Product_Cust_Behavior_Insights

| Scenario | File Name                                 | Key Focus |
|----------|--------------------------------------------|-----------|
| 9        | `04_hopify_top_products_analysis.sql`      | Top products by revenue, category, and segment |
| 10       | `05_hopify_customer_seg_behavior.sql`      | Behavior patterns by customer segment (churn, orders, product mix) |
| 11       | `08_hopify_customer_acquisition_analysis.sql` | New customer acquisition trends by channel |
| 12       | `11_hopify_active_users_analysis.sql`      | Active users by segment, usage frequency, and orders |

---

Each project folder supports an independent narrative, but the full suite forms a comprehensive SaaS KPI dashboard. All files depend on the same Hopify v15 schema and benchmark logic.
