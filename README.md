# Hopify SaaS Simulated Database (v1)

Welcome to the **Hopify SaaS Simulated Database (v1)** — a fictional but business-realistic SQLite database designed for SQL practice, SaaS KPI modeling, and data storytelling.  
This dataset simulates the structure, scale, and behavior of a mid-to-large SaaS company inspired by real-world operators like Shopify.

---

## 📦 Dataset Overview

**Hopify** is a fictional enterprise SaaS company providing e-commerce enablement, payments, and marketplace apps to global customers.

This database includes:

| Table                 | Description                                             |
|-----------------------|---------------------------------------------------------|
| customers             | Customer profiles with segments and signup timestamps  |
| subscriptions         | Subscription history per customer with change types    |
| orders                | Customer order headers with timestamps and totals      |
| order_items           | Detailed product line items per order                  |
| payments              | Payment records linked to orders                       |
| churn_events          | Churn logs including reason and timestamp              |
| locations             | 5 global Hopify office locations                       |
| app_installs          | Apps installed per office location                     |
| support_tickets       | Support tickets with created and resolved timestamps   |
| discounts             | Discount campaigns                                     |
| order_discounts       | Discounts applied to orders                            |
| products              | Core marketplace apps/services                         |
| themes                | Storefront themes available in the Hopify marketplace  |

---

## 🌍 Business Simulation Parameters

- **50,000 Customers**
- **5 Global Office Locations**
- **20 Core Marketplace Products**
- **Subscription Plan Tiers** (Starter to Plus)
- **Subscription History** including upgrades, downgrades, and reactivations
- **Full Timestamping** (`YYYY-MM-DD HH:MM:SS`) for all key events

---

## 🛠 Key Use Cases

- SQL KPI calculation practice (MRR, churn rate, NRR, ARPU, etc.)
- SaaS order lifecycle analysis
- Subscription history exploration
- Churn driver analysis
- Payments reconciliation
- Support ticket operational analysis

---

## ⚡ Getting Started

1. Download the `hopify_saas_realistic_v8.db` SQLite file.
2. Open it in your favorite **SQL editor that supports SQLite**, such as:
   - DB Browser for SQLite
   - DBeaver
   - SQLiteStudio
   - Azure Data Studio (with SQLite extension)
3. Run SQL queries using the included **query pack** or your own explorations.

---

## 📊 Sample KPIs to Explore

- Monthly Recurring Revenue (MRR)
- Net Revenue Retention (NRR)
- Churn Rate by plan
- Average Order Value (AOV)
- Support Ticket Resolution Time
- App Installs per Location

---
## 🔗 Data Model Overview

The Hopify v8 database is designed to simulate a realistic SaaS business structure, reflecting key components such as customers, subscriptions, orders, payments, and support interactions.

This relational model supports essential SaaS analytics, customer lifecycle analysis, and revenue modeling.

### Key Highlights:
- **Customers & Subscriptions**: Tracks active, churned, upgraded, and downgraded subscriptions linked to customer profiles.
- **Orders & Payments**: Captures orders and payments across the customer lifecycle.
- **Churn Events & Support Tickets**: Logs churn events and support ticket history to analyze customer behavior and retention drivers.
- **Marketplace Ecosystem**: Tracks app installs by location, product purchases, and applied discounts.

The model is fully normalized with foreign key constraints ensuring data integrity, enabling users to confidently explore relationships across entities.

> 💡 The included ER diagram provides a visual overview of these relationships.

---

## 🧩 ER Diagram

The ER (Entity-Relationship) diagram below visualizes the Hopify v8 data model and its key relationships.

Each table is connected by foreign key constraints, providing a clear view of how customers, subscriptions, orders, payments, and other entities interact within the Hopify SaaS ecosystem.

### 📥 Download ER Diagram
- [Hopify v1 Data Model - PNG]()
- [Hopify v1 Data Model - PDF]()

> The diagram is designed in landscape orientation for easy review and supports data storytelling, SaaS KPI modeling, and process flow analysis.


---

## 📄 SQL Query Pack

```sql
-- Monthly Recurring Revenue (MRR) by Month and Plan

SELECT 
    strftime('%Y-%m', start_date) AS month,
    plan_type,
    SUM(subscription_price) AS mrr
FROM subscriptions
WHERE status = 'active'
GROUP BY month, plan_type
ORDER BY month;
```

```sql
-- Monthly Churn Rate (%)

WITH cohort AS (
    SELECT 
        strftime('%Y-%m', start_date) AS month,
        COUNT(DISTINCT customer_id) AS starting_customers
    FROM subscriptions
    GROUP BY month
),
churned AS (
    SELECT 
        strftime('%Y-%m', end_date) AS month,
        COUNT(DISTINCT customer_id) AS churned_customers
    FROM subscriptions
    WHERE status = 'cancelled'
    GROUP BY month
)
SELECT
    c.month,
    c.starting_customers,
    COALESCE(ch.churned_customers, 0) AS churned_customers,
    ROUND(COALESCE(ch.churned_customers, 0) * 1.0 / c.starting_customers * 100, 2) AS churn_rate_percent
FROM cohort c
LEFT JOIN churned ch ON c.month = ch.month
ORDER BY c.month;
```

```sql
-- Net Revenue Retention (NRR) — Basic Simulation

SELECT 
    strftime('%Y-%m', start_date) AS month,
    ROUND(SUM(CASE WHEN change_type = 'upgrade' THEN subscription_price ELSE 0 END) * 1.0 /
          SUM(CASE WHEN change_type = 'signup' THEN subscription_price ELSE 0 END) * 100, 2) AS nrr_percent
FROM subscriptions
GROUP BY month
ORDER BY month;
```

```sql
-- Average Order Value (AOV) by Month

SELECT
    strftime('%Y-%m', order_date) AS month,
    ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
GROUP BY month
ORDER BY month;
```

```sql
-- Support Ticket Average Resolution Time (Hours)

SELECT
    ROUND(AVG(julianday(resolved_at) - julianday(created_at)) * 24, 2) AS avg_resolution_hours
FROM support_tickets;
```

```sql
-- App Installs per Location

SELECT 
    l.name AS location,
    COUNT(ai.install_id) AS installs
FROM locations l
JOIN app_installs ai ON l.location_id = ai.location_id
GROUP BY l.name;
```
---

