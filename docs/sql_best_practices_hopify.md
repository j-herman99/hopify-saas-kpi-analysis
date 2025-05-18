# 🧾 SQL Best Practices – Hopify Analysis

This style guide ensures consistency and readability across all scenario-driven SQL scripts.

## ✅ File Naming
- Use lowercase and hyphens: `3-hopify_cohort_retention_analysis.sql`
- Prefix with scenario number for sorting
- Keep names aligned with business scenario labels

## 🧱 Structure
```sql
-- Header comment block
-- Scenario: Revenue Trend Breakdown
-- Author: Jade Herman
-- Description: Calculates monthly NRR / GRR using invoice and payment data

WITH ...

SELECT ...
```

## 📌 Patterns to Prefer
- Use CTEs for modular logic
- Window functions for cohort and churn metrics
- Use `DATE()` functions to normalize time
- Use `COALESCE()` to handle nulls cleanly

## 🚫 Avoid
- Hardcoded customer IDs or date ranges (use dynamic or relative dates)
- Subqueries where a CTE would be clearer