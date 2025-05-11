# Hopify SaaS Realistic Practice Database (v8)

Welcome to the **Hopify SaaS Realistic Database (v8)** — a fictional but business-realistic SQLite database designed for SQL practice, SaaS KPI modeling, and data storytelling.  
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

## ⚖ License

This project is licensed under the [Apache 2.0 License](LICENSE).

---


