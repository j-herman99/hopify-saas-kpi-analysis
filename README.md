# 🚀 Hopify SaaS Simulated Database (v1)

Welcome to the **Hopify SaaS Simulated Database (v1)** — a fictional but business-realistic SQLite database designed for SQL practice, SaaS KPI modeling, and data storytelling.

This latest version is optimized with **dynamic multi-year scaling, segment-aware behaviors, support friction modeling, benchmarks table, marketing metrics**, and realistic web traffic.

---

## 📦 Dataset Overview

**Hopify** is a fictional SaaS company providing e-commerce enablement, payments, and marketplace apps to global customers.

| Table                 | Description                                         | Key Fields                                  |
|-----------------------|-----------------------------------------------------|----------------------------------------------|
| customers             | Customer profiles, segment, acquisition source     | `customer_id`, `signup_date`, `segment`, `acquisition_source` |
| subscriptions         | Subscription lifecycle with change tracking        | `subscription_id`, `customer_id`, `plan_type`, `status`, `change_type` |
| orders                | Customer order headers with totals                 | `order_id`, `customer_id`, `order_date`, `total_amount` |
| order_items           | Product line items per order                       | `order_item_id`, `order_id`, `product_id`, `quantity`, `subtotal` |
| payments              | Payments linked to orders                          | `payment_id`, `customer_id`, `payment_amount`, `payment_date` |
| churn_events          | Churn logs including reason and timestamp          | `churn_id`, `customer_id`, `churn_date`, `churn_reason` |
| support_tickets       | Support tickets per customer, with SLA modeling    | `ticket_id`, `customer_id`, `created_at`, `resolved_at`, `ticket_category` |
| app_installs          | App installs by office location                    | `install_id`, `location_id`, `product_id`, `install_date` |
| discounts             | Discount campaigns                                 | `discount_id`, `discount_code`, `discount_percent`, `start_date` |
| order_discounts       | Discounts applied to orders                        | `order_id`, `discount_id` |
| products              | Core marketplace apps and services                 | `product_id`, `name`, `category`, `price`, `revenue_type` |
| locations             | Hopify office locations                            | `location_id`, `city`, `country` |
| marketing_campaigns    | Marketing campaign spend by channel and type      | `campaign_id`, `campaign_name`, `channel`, `campaign_type`, `total_cost` |
| web_traffic           | Monthly web traffic by channel with leads & MQLs   | `traffic_id`, `traffic_date`, `source_channel`, `visitors`, `leads`, `mqls` |
| benchmarks            | Target benchmarks for KPIs (MRR, Churn, NRR, etc.) | `benchmark_id`, `category`, `metric_name`, `target_value` |

---

## 🌍 Business Simulation Parameters

- **50,000+ Customers across 3 segments (SMB, Mid-Market, Enterprise)**
- **Multi-year historical data (dynamic up to 3 years)**
- **Segment-aware behavior on orders, subscriptions, support, churn**
- **Product category skew by segment**
- **Dynamic order, product, and support friction modeling**
- **Integrated benchmarks and marketing metrics**
- **Dynamic acquisition plan with spikes & dips (seasonality aware)**

---

## 🛠 Key Use Cases

- SQL KPI calculation practice (MRR, churn rate, NRR, GRR, ARPU, etc.)
- Churn & retention analysis by segment, cohort, and customer lifecycle
- Expansion revenue vs net new revenue breakdown
- LTV (Lifetime Value) modeling by segment
- Web traffic to lead/MQL conversion analysis
- Campaign spend vs web traffic trends
- Benchmarks vs actual performance reporting
- Support ticket friction vs churn risk modeling
- Customer acquisition tracking by source and campaign
- Product penetration & cross-sell analysis by segment

---

## 📊 Sample Business Scenarios to Explore

| Scenario # | Business Case                               | Example Analysis                            |
|------------|---------------------------------------------|----------------------------------------------|
| 1          | Churn Analysis                              | Churn rate by month, segment                 |
| 2          | Revenue Trend Breakdown                     | MRR, GRR, NRR over time                      |
| 3          | Cohort Retention Analysis                   | Signup cohorts & retention curves            |
| 4          | Top Product Categories by Revenue           | Revenue by product category                  |
| 5          | Customer Segmentation Behavior              | Order volume, support by segment             |
| 6          | Support Ticket Volume vs Churn Risk         | Support interactions vs churn probability    |
| 7          | NRR & GRR Analysis                          | NRR, GRR by month and segment                |
| 8          | Customer Acquisition Trend                  | New customers per month, source-based        |
| 9          | Expansion Revenue Analysis                  | Upsell/cross-sell revenue from existing base |
| 10         | LTV by Segment                              | Lifetime Value by segment                    |
| 11         | Active User Growth                          | Monthly active customers trend               |
| 12         | ARPU by Segment                             | Average Revenue Per User trend               |
| 13         | Marketing Performance vs Goals (Benchmarks) | Web traffic vs campaign spend, MQLs, CAC     |

---

## 🗺 Data Model Diagram (ERD)

The model is fully normalized, reflecting realistic SaaS relational structures.

> ✅ ERD provided in PNG and PDF formats in the project pack.

---

## 📂 Project Files

| File                          | Description                          |
|-------------------------------|--------------------------------------|
| hopify_saas_v1.py             | Python generator script (v1)        |
| hopify_saas_v1.db             | SQLite database file (generated)     |
| ERD_hopify_saas_v1.png        | ER diagram (PNG)                     |
| ERD_hopify_saas_v1.pdf        | ER diagram (PDF)                     |
| sql_queries_v1_starter_pack.sql | SQL starter pack                    |
| sql_queries_v1_full_pack.sql  | SQL full analysis pack               |
| sql_queries_v1_markdown.md    | SQL pack in markdown format          |
| README.md                     | This README                          |

---

## 🧩 Getting Started

1. Open the `.db` file using any SQL client that supports SQLite:
   - DB Browser for SQLite
   - DBeaver
   - SQLiteStudio
   - Azure Data Studio (with SQLite extension)
2. Use the provided SQL query packs or explore custom SaaS KPIs.

---

## 📄 License

Apache 2.0 License  
This dataset and generator scripts are provided under Apache 2.0 license.

