# 🧠 Hopify SQL Scripts

This folder contains all finalized SQL scripts used in the KPI analysis of the Hopify SaaS dataset. Scripts are organized by project, with scenario mappings and best practices included for context and reuse.

## 📁 Folder Structure

- `01_project_churn_retention_analysis/`  
  Customer churn, retention, and cohort survival metrics.

- `02_project_revenue_profit_analysis/`  
  Revenue breakdowns, NRR/GRR trends, CAC, LTV, ARPU.

- `03_project_product_cust_behavior_insights/`  
  Segment behavior, top products, order trends, support volumes.

- `hopify_sql_best_practices.md`  
  Common SQL tips and standards used across all scripts.

- `hopify_sql_scenarios_index.md`  
  Scenario-to-file map across all 3 analysis projects.

## 🧩 SQL Usage Notes

- Compatible with the Hopify v15 dataset schema.
- All scripts assume the presence of a populated `benchmarks` table and valid historical data across key dimensions: `Segment`, `Signup Month`, `Product`, `Support`, and `Churn Events`.
- Scripts are designed for both direct analysis and dashboard integration (e.g., Power BI, Tableau).

## ✅ Scenario Mapping

For a project-by-project index of all SQL analysis scenarios, see [`hopify_sql_scenarios_index.md`](hopify_sql_scenarios_index.md).