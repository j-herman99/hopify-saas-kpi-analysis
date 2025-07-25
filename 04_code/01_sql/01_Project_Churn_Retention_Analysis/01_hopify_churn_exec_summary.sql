/* 
==================================================================================================
📄 Filename     : 01_churn_exec_summary.sql
📅 Created On   : 2025-05-13
📝 Description  : Executive Summary – Most Recent Churn Rate by Segment vs Benchmark
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ==================================================================================================
-- 1. Executive Summary: Most Recent Churn Rate by Segment vs Benchmark
-- ==================================================================================================


WITH last_complete_month AS (
    SELECT 
        MAX(strftime('%Y-%m', ce.churn_date)) AS latest_month,
        date(MAX(date(ce.churn_date)), 'start of month') AS month_start
    FROM churn_events as ce
),

monthly_churn AS (
    SELECT 
        strftime('%Y-%m', ce.churn_date) AS month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM churn_events ce
    JOIN customers c ON ce.customer_id = c.customer_id
    GROUP BY month, c.customer_segment
),

active_customers_base AS (
    SELECT 
        lm.latest_month AS month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM customers c
    JOIN last_complete_month lm
    LEFT JOIN churn_events ce ON c.customer_id = ce.customer_id
    WHERE c.signup_date < lm.month_start
      AND (ce.churn_date IS NULL OR date(ce.churn_date) >= lm.month_start)
    GROUP BY c.customer_segment
),

benchmarks_filtered AS (
    SELECT segment, target_value
    FROM benchmarks
    WHERE metric_name = 'Monthly Churn Target (%)'
),

support_summary AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(st.ticket_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_tickets_per_customer,
        ROUND(AVG(julianday(st.resolved_at) - julianday(st.created_at)), 2) AS avg_resolution_days
    FROM customers c
    LEFT JOIN support_tickets st ON c.customer_id = st.customer_id
    GROUP BY c.customer_segment
)

SELECT
    mc.month AS "Month",
    mc.customer_segment AS "Segment",
    mc.churned_customers AS "Churned Customers",
    ac.active_customers AS "Active Customers",
    ROUND(mc.churned_customers * 100.0 / ac.active_customers, 2) AS "Churn Rate %",
    ROUND((1.0 - mc.churned_customers * 1.0 / ac.active_customers) * 100, 2) AS "Retention %",
    bf.target_value AS "Benchmark %",
    ROUND(ROUND(mc.churned_customers * 100.0 / ac.active_customers, 2) - bf.target_value, 2) AS "Variance %",
    ss.avg_tickets_per_customer AS "Avg. Support Tickets",
    ss.avg_resolution_days AS "Avg. Resolution Days"
FROM 
    monthly_churn mc
JOIN last_complete_month lm ON mc.month = lm.latest_month
JOIN active_customers_base ac 
    ON mc.customer_segment = ac.customer_segment AND mc.month = ac.month
LEFT JOIN benchmarks_filtered bf 
    ON mc.customer_segment = bf.segment
LEFT JOIN support_summary ss 
    ON mc.customer_segment = ss.customer_segment
ORDER BY mc.customer_segment;