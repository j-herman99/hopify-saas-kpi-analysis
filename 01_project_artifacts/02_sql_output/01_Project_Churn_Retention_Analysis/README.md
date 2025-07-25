# 📊 Project 1: Churn & Retention Analysis – SQL Outputs

This folder contains CSV files exported from SQL analyses related to churn and retention behavior across customer segments, support interactions, and time-based cohorts.

## Included SQL Output Files

| Filename                                  | Description |
|-------------------------------------------|-------------|
| `01_hopify_churn_seg_v_benchmark.csv`     | Monthly churn rate by segment vs benchmark |
| `01_hopify_churn_signup_cohort_seg.csv`   | Signup cohort breakdown by segment |
| `01_hopify_cohort_retention_v_churned.csv`| Retention vs churned count by cohort |
| `01_hopify_exec_summary_churn.csv`        | Executive summary of churn insights |
| `01_hopify_retention_cohort_seg_churn.csv`| Retention cohort matrix by segment |
| `03_hopify_pivot_ret_matrix.csv`          | Pivoted matrix of retention by category |
| `03_hopify_retention_curve.csv`           | Retention decay by signup cohort |
| `03_hopify_seg_retention.csv`             | Retention over time by segment |
| `06_hopify_churn_risk_v_tickets_vol.csv`  | Churn rate vs support ticket volume group |

---

To regenerate these files, re-run the corresponding queries in `/sql/01_Project_Churn_Retention_Analysis/`.

# 📊 Project 1: Churn & Retention Analysis – SQL Outputs

This folder contains SQL-generated output files used to analyze customer churn behavior, retention trends, and support ticket impact across different segments in the Hopify SaaS dataset.

The outputs support deep dives into:
- Monthly churn rates and segment benchmarks
- Cohort-based retention tracking
- Correlations between support interactions and churn
- Executive summaries and pivoted retention matrices for stakeholder reporting

---

## 🗂️ Included SQL Output Files

### 🔁 Retention & Churn by Segment and Cohort

| Filename                                  | Description |
|-------------------------------------------|-------------|
| `01_hopify_churn_seg_v_benchmark.csv`     | Monthly churn rate by segment vs benchmark |
| `01_hopify_churn_signup_cohort_seg.csv`   | Signup cohort breakdown by segment |
| `01_hopify_retention_cohort_seg_churn.csv`| Retention cohort matrix by segment |
| `03_hopify_pivot_ret_matrix.csv`          | Pivoted matrix of retention by category |
| `03_hopify_retention_curve.csv`           | Retention decay by signup cohort |
| `03_hopify_seg_retention.csv`             | Retention over time by segment |
| `01_hopify_cohort_retention_v_churned.csv`| Retained vs churned counts by cohort |

### 🧠 Summary & Support Correlation

| Filename                                  | Description |
|-------------------------------------------|-------------|
| `01_hopify_exec_summary_churn.csv`        | Executive summary of churn metrics |
| `06_hopify_churn_risk_v_tickets_vol.csv`  | Churn rate vs support ticket volume group |

---

## 🔁 How to Regenerate

These outputs are generated from SQL queries in the folder: /01_sql/01_Project_Churn_Retention_Analysis/

To update or reproduce the files, rerun the scripts in that directory and export the results as CSV.