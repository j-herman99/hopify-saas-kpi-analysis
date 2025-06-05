# 💻 Hopify SaaS DB Generator  

![SaaS](https://img.shields.io/badge/SaaS-Simulation-blueviolet)
![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)
![SQL](https://img.shields.io/badge/SQL-SQLite-lightgrey?logo=sqlite)
![Data Generation](https://img.shields.io/badge/Data-Synthetic-green)
![Customer Lifecycle](https://img.shields.io/badge/Customer-Lifecycle-orange)

**Version:** `v1.0`  
📅 Released: May 2025

A Python-based generator that creates a realistic, benchmark-aware **B2B SaaS customer lifecycle database** for Hopify. It simulates acquisition, subscriptions, churn, and segment behavior across `SMB`, `Mid-Market`, and `Enterprise` tiers, producing a normalized SQLite database for downstream analysis.

---

## 🧠 Overview

This repository generates a clean, multi-year, segment-aware **SQLite database** (`hopify_saas_v1.db`) that serves as the foundation for SaaS KPI modeling, churn analysis, and revenue forecasting. The dataset is fully synthetic and reflects real-world B2B customer behavior.

It is designed for use by **data analysts, business students, and product teams** looking to practice SQL, Python, cohort modeling, and SaaS metrics in a realistic simulation environment. Built entirely in Python with benchmark targeting, it enables faster prototyping and hands-on exploration of customer lifecycle analytics.

---

## 📁 Repository Structure

```text
/benchmarks/   → KPI benchmark values (CSV) used directly in database generation  
/data/         → Zipped SQLite database output: hopify_saas_v1.db  
/docs/         → Dataset overview and generation script section-by-section guide  
/visuals/      → ERD diagrams (DBeaver PNG + PDF)  
hopify_db_v1_gen.py → Main script (Python v15 generator)  
README.md      → Root-level project overview  
requirements.txt → Environment setup file
```

---

## 📊 Project Architecture Diagrams

The following visuals illustrate the structural logic and table relationships:

- 🧩 [ERD (DBeaver PNG)](visuals/hopify_v1_erd_dbeaver.png) — Visual layout of all tables and connections  
- 📄 [ERD (DBeaver PDF)](visuals/hopify_v1_erd_dbeaver.pdf) — Print-ready version for documentation or presentations  

🔗 Example output: [`hopify_saas_v1.db.zip`](data/hopify_saas_v1.db.zip)

---

## 🔧 Features & Simulation Logic

| ✅ Module                    | Description                                                                |
|-----------------------------|-----------------------------------------------------------------------------|
| Segment-aware simulation    | Customers behave differently by segment: SMB, Mid-Market, Enterprise        |
| Multi-year cohort modeling  | Customer acquisition trends evolve month-to-month over a 3-year period      |
| Churn & retention decay     | Churn risk decreases with tenure and varies by support history              |
| Benchmarks table            | Reads target KPI benchmarks from CSV during generation                      |
| ERD + visual documentation  | DBeaver-based schema diagrams for storytelling and analysis                 |

---

## 📄 Documentation

This project includes full documentation for both the database structure and the script logic behind it:

- 🗂️ [`Dataset Overview`](docs/hopify_db_dataset_overview.md)  
  Explains the schema design, table relationships, and key fields in the SQLite file.

- 🧑‍💻 [`Developer Notes: hopify_db_gen Section-by-Section Guide`](docs/hopify_db_gen_section_notes.md)  
  Provides commentary on `hopify_db_v1_gen.py`, including logic, structure, and business reasoning.

---

## 🔗 Related Projects

Looking for the analysis side of this project?

👉 Check out the companion repository: **[Hopify SaaS KPI Analysis](https://github.com/j-herman99/hopify-saas-kpi-analysis)**  

Includes SQL queries, cohort analysis, KPI benchmarking, retention heatmaps, and Python-powered insights built on the database from this repo.

---
