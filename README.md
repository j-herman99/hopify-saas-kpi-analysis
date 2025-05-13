
# 🚀 Hopify SaaS Simulated Database (v1)

Welcome to the **Hopify SaaS Simulated Database (v1)** — a fictional but business-realistic SQLite database designed for SQL practice, SaaS KPI modeling, and data storytelling.  
This dataset simulates the structure, scale, and behavior of a mid-to-large SaaS company inspired by operators like Shopify, now enhanced with segment-aware behaviors, support friction, lifecycle churn modeling, and expansion revenue modeling.

## 📦 Dataset Overview

**Hopify** is a fictional SaaS company providing e-commerce enablement, payments, and marketplace apps to global customers.

This database includes:

| Table               | Description                                            |
|---------------------|--------------------------------------------------------|
| customers           | Customer profiles with segments, signup timestamps, and acquisition source |
| subscriptions       | Subscription history per customer with change types    |
| orders              | Customer order headers with timestamps and totals      |
| order_items         | Detailed product line items per order                  |
| payments            | Payment records linked to orders (with 3% simulated failures) |
| churn_events        | Churn logs including reason, timestamp, and behavior-based adjustments |
| support_tickets     | Support tickets with created, resolved timestamps, and SLA behavior by segment |
| locations           | 5 global Hopify office locations                      |
| app_installs        | Apps installed per office location                    |
| discounts           | Discount campaigns                                    |
| order_discounts     | Discounts applied to orders                           |
| products            | Marketplace apps/services, including free and premium |

## 🌍 Business Simulation Parameters

- 50,000 Customers across SMB, Mid-Market, Enterprise segments
- 5 Global Office Locations
- 80 Products (30 static, 50 dynamically generated)
- Segment-aware orders, subscriptions, support volume, and churn risk
- Subscription Plan Tiers (Starter to Plus)
- Realistic lifecycle modeling including upgrades, downgrades, reactivations
- Support SLA realism by customer segment
- Full Timestamping (`YYYY-MM-DD HH:MM:SS`) across all activities

## 🛠 Key Use Cases

- SQL KPI calculation practice (MRR, churn rate, NRR, GRR, ARPU, etc.)
- Churn & retention analysis by segment and cohort
- Expansion revenue vs new business revenue breakdown
- Lifetime Value (LTV) by segment
- Customer acquisition trend analysis (with campaign tagging)
- Support ticket volume vs churn risk modeling
- Active user growth tracking (orders & payments)
- Cross-sell and product category penetration analysis

## 🚀 Getting Started

1. Download the `hopify_saas_v1.db`.
2. Open the `.db` file using your favorite SQL editor that supports SQLite:
   - DB Browser for SQLite
   - DBeaver
   - SQLiteStudio
   - Azure Data Studio (with SQLite extension)
3. Use the provided SQL query packs or build your own queries to explore SaaS KPIs.

## 🔗 Data Model Overview

The Hopify v11 database simulates a modern SaaS business structure, supporting advanced analytics, customer lifecycle modeling, and revenue breakdowns.

### 🔍 Key Highlights

- Customers & Subscriptions: Lifecycle tracking with behavior-adjusted churn modeling.
- Orders & Payments: Captures realistic SaaS transactions and payment failures.
- Support & Churn: Integrates support ticket history, billing issues, resolution times into churn modeling.
- Marketplace Ecosystem: Tracks app installs by location, product usage, and applied discounts.

The model is fully normalized with foreign key constraints ensuring data integrity, enabling users to confidently explore relationships across entities.

## 📊 Sample Business Scenarios to Explore

| Scenario # | Business Case                         | Example Analysis                             |
|------------|--------------------------------------|----------------------------------------------|
| 1          | Churn Analysis                       | Churn rate by month, segment                |
| 2          | Revenue Trend Breakdown              | MRR, GRR, NRR over time                     |
| 3          | Cohort Retention Analysis            | Signup cohorts & retention curves           |
| 4          | Top Product Categories by Revenue    | Revenue by product category                 |
| 5          | Customer Segmentation Behavior       | Order volume, support by segment            |
| 6          | Support Ticket Volume vs Churn Risk  | Support interactions vs churn probability   |
| 7          | NRR & GRR Analysis                   | Net Revenue Retention, Gross Revenue Retention by month and segment |
| 8          | Customer Acquisition Trend           | New customers per month, source-based       |
| 9          | Expansion Revenue Analysis           | Upsell/cross-sell revenue from existing base |
| 10         | LTV by Segment                       | Lifetime Value by customer segment          |
| 11         | Active User Growth                   | Monthly active customers trend              |
| 12         | ARPU by Segment                      | Average Revenue Per User trend              |

## 📄 License

Apache 2.0 License

This dataset and generator scripts are provided under Apache 2.0 license.  
See the LICENSE file for details.
