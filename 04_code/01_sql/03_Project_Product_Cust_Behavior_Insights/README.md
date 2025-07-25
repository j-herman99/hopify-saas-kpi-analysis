# 🛍️ Hopify SaaS Project - Part 3: Product & Customer Behavior Insights

This project analyzes behavioral patterns across Hopify’s customer base to identify key trends in product usage, support interaction, and active user engagement. Insights inform customer success strategies, product prioritization, and churn mitigation.

---

## 📊 Included SQL Scenarios

| File Name                                                   | Focus Area |
|--------------------------------------------------------------|------------|
| `00_hopify_project_product_customer_insights_analysis.sql`   | Master query – orchestrates all key insights |
| `01_hopify_top_product_category_summary.sql`                 | Top product categories by revenue |
| `02_hopify_top_categories_by_segment.sql`                    | Top categories by customer segment |
| `03_hopify_top_10_products_by_segment.sql`                   | Top 10 individual products by segment |
| `04_hopify_aov_by_segment_and_category.sql`                  | AOV breakdown by segment and category |
| `05_hopify_cross_sell_product_combos.sql`                    | Cross-sell combos and combo frequency by segment |
| `06_hopify_segment_behavior_summary.sql`                     | Segment-level churn, AOV, support, and subscription activity |
| `07_hopify_monthly_churn_rate.sql`                           | Monthly churn rates by segment |
| `08_hopify_churn_rate_lifetime.sql`                          | Snapshot of lifetime churn across segments |
| `09_hopify_avg_subscription_revenue.sql`                     | Avg subscription revenue by segment |
| `10_hopify_order_behavior_by_segment.sql`                    | Orders per customer and avg items per order |
| `11_hopify_support_tickets_by_segment.sql`                   | Volume and resolution time of support tickets |
| `12_hopify_recent_active_users.sql`                          | Most recent active users by segment |
| `13_hopify_monthly_active_customers_by_segment.sql`          | Monthly active customer trends by segment |
| `14_hopify_unique_active_customers.sql`                      | Unique active users over time |
| `15_hopify_rolling_avg_active_customers.sql`                 | Rolling 3-month average active customer count |
| `16_hopify_cac_v_payback_period_seg.sql`                     | CAC payback period by segment |

---

## 🔍 Key Business Questions Answered

- Which products and categories drive the most revenue?
- Which segments have the highest churn or require the most support?
- Are we seeing effective cross-sell strategies by customer group?
- How quickly do we recover CAC through subscriptions?
- What’s the trend in customer activity and retention over time?

---

## 📁 Output Location

Corresponding analysis output:  
`01_project_artifacts/02_sql_output/03_project_product_cust_behavior_insights/`