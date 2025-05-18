# 📊 Hopify v1 — SaaS KPI & Churn Analysis Project

**Version:** `v1.0`  
📅 Released: May 2025

A scenario-driven SQL project that analyzes SaaS customer behavior and KPI performance using the **Hopify v1** simulated database. Tracks churn, retention, LTV, CAC, and revenue metrics across `SMB`, `Mid-Market`, and `Enterprise` segments.

This project analyzes a simulated SaaS business dataset (**Hopify v1**) using SQL and Python to uncover key performance trends in revenue, churn, retention, and customer behavior. Ideal for showcasing business analytics, FP&A, and RevOps skills.

---

## 🎯 Project Goals

- Analyze **monthly churn rates**, **customer retention**, and **net revenue retention (NRR)**
- Evaluate **ARPU**, **LTV**, and **segment profitability** across SMB, Mid-Market, and Enterprise tiers
- Visualize **support ticket impact** on churn and model acquisition funnel behavior
- Demonstrate real-world application of SQL, Python, and SaaS financial metrics

---

## 🧩 Dataset Structure

Includes a realistic ERD covering:

| Table             | Description                              |
|------------------|------------------------------------------|
| `customers`       | Customer profiles and segmentation       |
| `subscriptions`   | Subscription history and status changes  |
| `orders`          | Customer purchases over time             |
| `payments`        | Revenue transactions incl. churn impact  |
| `products`        | SaaS product types and price plans       |
| `benchmarks`      | SaaS benchmark KPIs for analysis         |
| `support_tickets` | Ticket volume and resolution status      |
| `web_traffic`     | Simulated monthly site sessions/visits   |

📎 [View ERD](./hopify_v1_erd.png)

---

## 🔍 Key Analyses & Deliverables

- **Churn Rate Analysis** by Month & Segment
- **Retention Curve & Cohort Heatmaps**
- **NRR / GRR Revenue Impact Reports**
- **ARPU Trends & Segment Profitability**
- **LTV Estimation by Segment**
- **Support Ticket Impact on Churn**
- **Acquisition & Marketing Funnel Trends**

---

## 📊 Sample Visuals

| Churn Rate by Segment | Cohort Retention Heatmap |
|-----------------------|--------------------------|
| ![](screenshots/churn_rate_segment.png) | ![](screenshots/cohort_heatmap.png) |

---

## 📝 Reports & Insights

- Cohort Retention Executive Summary
- Revenue Growth & NRR Report
- LTV & Profitability Findings
- Segment-level Performance Reviews

---

## 🛠️ Tools & Skills Demonstrated

- SQL (window functions, CTEs, case logic)
- Python (Pandas, Matplotlib, Seaborn)
- SaaS Metrics: NRR, GRR, ARPU, LTV, CAC, Churn
- Data storytelling and dashboard design
- GitHub documentation & reproducibility

---

## ✅ What This Demonstrates

- Translating SaaS business questions into KPI-driven analysis.
- Strong SQL + Python application for real-world business metrics.
- Effective data storytelling & executive reporting.
- Practical RevOps, FP&A, and Business Analysis skill showcase.

---

## 📁 Project Structure

```plaintext
hopify-saas-kpi-v1/
├── data/
│   └── hopify_v1.db
├── scripts/
│   └── hopify_db_v1_gen.py
├── queries/
│   ├── sql_queries_v1_starter_pack.sql
│   ├── sql_queries_v1_full_pack.sql
│   └── sql_queries_v1_markdown.md
├── reports/
│   └── hopify_kpi_analysis_summary.pdf
├── visualizations/
│   ├── churn_rate_segment.png
│   ├── cohort_heatmap.png
├── assets/
│   └── hopify_v15_erd.png
└── README.md

```

---




