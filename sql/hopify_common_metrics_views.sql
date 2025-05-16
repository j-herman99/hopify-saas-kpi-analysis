/*
Created By: Jade Herman
Created On: 2025-05-15
Description: Common Views for Hopify SaaS KPI Metrics (v15)

This script defines reusable views for key SaaS KPIs: Churn Rate, NRR, GRR, ARPU, LTV, and Cohort Retention.

To use: RUN these view definitions once in your session or DB, then reference them in scenario-specific queries.
*/

-- View: Monthly Active Customers (Start of Month)
CREATE VIEW IF NOT EXISTS vw_monthly_active_customers AS
SELECT
    strftime('%Y-%m', ml.month_start) AS month,
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM (
    SELECT DISTINCT strftime('%Y-%m', signup_date) AS month_start FROM customers
    UNION
    SELECT DISTINCT strftime('%Y-%m', churn_date) FROM churn_events
) ml
JOIN customers c ON c.signup_date < date(ml.month_start || '-01')
GROUP BY month, c.customer_segment;

-- View: Monthly Churned Customers
CREATE VIEW IF NOT EXISTS vw_monthly_churned_customers AS
SELECT
    strftime('%Y-%m', ce.churn_date) AS month,
    c.customer_segment,
    COUNT(DISTINCT ce.customer_id) AS churned_customers
FROM churn_events ce
JOIN customers c ON ce.customer_id = c.customer_id
GROUP BY month, c.customer_segment;

-- View: Monthly Churn Rate by Segment
CREATE VIEW IF NOT EXISTS vw_churn_rate_by_segment AS
SELECT
    ma.month,
    ma.customer_segment,
    ma.active_customers,
    COALESCE(mc.churned_customers, 0) AS churned_customers,
    ROUND(COALESCE(mc.churned_customers, 0) * 1.0 / ma.active_customers * 100, 2) AS churn_rate_percent
FROM vw_monthly_active_customers ma
LEFT JOIN vw_monthly_churned_customers mc
    ON ma.month = mc.month AND ma.customer_segment = mc.customer_segment;

-- View: Monthly ARPU by Segment (Order-Based)
CREATE VIEW IF NOT EXISTS vw_arpu_by_segment AS
SELECT
    strftime('%Y-%m', o.order_date) AS month,
    c.customer_segment,
    ROUND(SUM(o.total_amount), 2) AS total_revenue,
    COUNT(DISTINCT c.customer_id) AS active_customers,
    ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS arpu
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY month, c.customer_segment;

-- View: Lifetime Value (Segment Level) using ARPU / Churn Proxy
CREATE VIEW IF NOT EXISTS vw_ltv_by_segment AS
WITH arpu AS (
    SELECT
        c.customer_segment,
        AVG(o.total_amount) AS avg_revenue_per_order,
        AVG(order_counts.num_orders) AS avg_orders_per_customer
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN (
        SELECT customer_id, COUNT(*) AS num_orders FROM orders GROUP BY customer_id
    ) order_counts ON c.customer_id = order_counts.customer_id
    GROUP BY c.customer_segment
),
churn AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id), 4) AS churn_rate
    FROM customers c
    LEFT JOIN churn_events ce ON c.customer_id = ce.customer_id
    GROUP BY c.customer_segment
)
SELECT
    a.customer_segment,
    ROUND(a.avg_revenue_per_order * a.avg_orders_per_customer, 2) AS arpu,
    c.churn_rate,
    CASE
        WHEN c.churn_rate > 0 THEN ROUND((a.avg_revenue_per_order * a.avg_orders_per_customer) / c.churn_rate, 2)
        ELSE NULL
    END AS estimated_ltv
FROM arpu a
JOIN churn c ON a.customer_segment = c.customer_segment;
