# 📊 Project 1: Churn & Retention Analysis

This folder contains SQL scripts used to analyze churn and retention patterns across Hopify's B2B SaaS customer segments. The queries support KPI benchmarking, cohort analysis, support impact modeling, and overall customer health summaries.

## SQL Scenario Index

| File Name                                           | Description |
|----------------------------------------------------|-------------|
| `00_hopify_project_churn_retention_analysis.sql`   | Master scenario script that compiles all key queries for this project |
| `01_hopify_churn_exec_summary.sql`                 | Executive summary of churn rates vs. benchmarks by segment |
| `02_hopify_churn_by_signup_cohort.sql`             | Monthly churn patterns by customer signup cohort |
| `03_hopify_monthly_churn_vs_benchmark.sql`         | Segment-level churn rates plotted against target benchmarks |
| `04_hopify_retention_by_cohort_churn_month.sql`    | Retention curve by signup cohort and churn month |
| `05_hopify_retention_milestones_by_cohort.sql`     | Key retention milestones by customer cohort (e.g., 30/90/180 days) |
| `06_hopify_retention_milestones_by_segment.sql`    | Retention milestones by customer segment (SMB, Mid-Market, Enterprise) |
| `07_hopify_retention_curve_by_signup_month.sql`    | Longitudinal retention curve grouped by signup month |
| `08_hopify_support_ticket_vs_churn_risk.sql`       | Analysis of support ticket volume and resolution time vs. churn likelihood |

## Business Questions Answered

- What is the average churn rate by customer segment?
- How do retention rates vary by cohort and time since signup?
- At what point in the customer lifecycle does churn peak?
- Does customer support engagement reduce churn risk?

> These SQL outputs directly power visualizations and summary metrics in the portfolio dashboard and executive presentation.
