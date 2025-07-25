/* 
==================================================================================================
📄 Filename     : 03_monthly_churn_vs_benchmark.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Churn Rate by Segment with Benchmark comparison and variance
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 3. Monthly Churn Rate by Segment with Benchmark
-- ===============================================================================================

WITH monthly_churn AS (
    SELECT 
        strftime('%Y-%m', DATE(ce.churn_date)) AS churn_month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM 
        churn_events AS ce
    JOIN customers AS c 
        ON ce.customer_id = c.customer_id
    GROUP BY 
        churn_month, c.customer_segment
),

monthly_active AS (
    SELECT 
        strftime('%Y-%m', DATE(ml.date)) AS active_month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM (
        SELECT DISTINCT date(strftime('%Y-%m', churn_date) || '-01') AS date
        FROM churn_events
        WHERE strftime('%Y-%m', churn_date) < strftime('%Y-%m', 'now')
    ) AS ml
    JOIN customers AS c
        ON c.signup_date < ml.date
    LEFT JOIN churn_events AS ce
        ON c.customer_id = ce.customer_id
    WHERE ce.churn_date IS NULL OR DATE(ce.churn_date) >= ml.date
    GROUP BY 
        active_month, c.customer_segment
),

benchmarks_resolved AS (
    SELECT 
        s.segment,
        COALESCE(b1.target_value, b2.target_value) AS target_value
    FROM 
        (SELECT DISTINCT customer_segment AS segment FROM customers) AS s
    LEFT JOIN benchmarks AS b1 
        ON b1.segment = s.segment AND b1.metric_name = 'Monthly Churn Target (%)'
    LEFT JOIN benchmarks AS b2 
        ON b2.segment = 'All Segments' AND b2.metric_name = 'Monthly Churn Target (%)'
)

SELECT
    mc.churn_month AS "Month",
    mc.customer_segment AS "Segment",
    mc.churned_customers AS "Churned Customers",
    ma.active_customers AS "Active Customers",
    ROUND(mc.churned_customers * 100.0 / ma.active_customers, 2) AS "Churn Rate %",
    b.target_value AS "Benchmark Churn Rate %",
    ROUND(ROUND(mc.churned_customers * 100.0 / ma.active_customers, 2) - b.target_value, 2) AS "Variance %"
FROM 
    monthly_churn AS mc
JOIN 
    monthly_active AS ma 
    ON mc.churn_month = ma.active_month 
    AND mc.customer_segment = ma.customer_segment
LEFT JOIN 
    benchmarks_resolved AS b 
    ON mc.customer_segment = b.segment
ORDER BY 
    mc.churn_month DESC, mc.customer_segment;