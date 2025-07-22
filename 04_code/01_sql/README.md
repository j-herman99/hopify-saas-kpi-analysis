# 🧠 SQL Analysis Pack – Hopify KPI Project

This folder contains all core SQL scripts used in the Hopify SaaS KPI analysis project. Each script maps to a distinct business scenario and is designed for reproducibility, benchmarking, and executive reporting.

---

## 🗃 Scenario Scripts (1–13)

These files are organized by scenario number and focus area:

| Scenario | File | Description |
|----------|------|-------------|
| 1 | `1-hopify_churn_analysis.sql` | Monthly churn + retention breakdown |
| 2 | `2-hopify_revenue_analysis.sql` | Revenue trends and ARPU breakdown |
| 3 | `3-hopify_cohort_retention_analysis.sql` | Retention curve by cohort |
| 4 | `4-hopify_top_products_analysis.sql` | Top products and category revenue |
| 5 | `5-hopify_customer_seg_behavior.sql` | Segment behavior (orders, churn, support) |
| 6 | `6-hopify_stickets_vs_churn.sql` | Ticket volume and churn risk |
| 7 | `7-hopify_nrr_grr_analysis.sql` | NRR and GRR by month and segment |
| 8 | `8-hopify_customer_acquistion_analysis.sql` | Monthly new customer growth |
| 9 | `9-hopify_expansion_rev_analysis.sql` | Expansion vs net new revenue |
| 10 | `10-hopify_ltv_segment_analysis.sql` | Lifetime Value by segment |
| 11 | `11-hopify_active_users_analysis.sql` | Active user trends based on payments |
| 12 | `12-hopify_avg_rev_user_analysis.sql` | ARPU with segment benchmarks |
| 13 | `13-hopify_benchmarks_table_updates.sql` | Inserts & updates for benchmarks table |

---

## 🧩 Shared Views & Reusables

| File | Purpose |
|------|---------|
| `hopify_common_metrics_views.sql` | Defines views for churn, LTV, NRR, GRR, ARPU |
| `universal_kpi_script.sql` | Unified query for multiple KPIs + benchmarks |
| `hopify_sql_scenarios_index.md` | Markdown table linking each scenario to its use case |

---

## 📑 Style & Best Practices

Follow the formatting and design guidance in:

📄 [`sql_best_practices_hopify.md`](sql_best_practices_hopify.md)

---

## 🧪 Usage Tips

- All queries assume you're connected to `hopify_saas_v1.db`
- You can test scripts directly in DBeaver, DB Browser, or SQLite CLI
- For Power BI / Excel use, export results from the SQL client or reference from `/sql_outputs/`

---