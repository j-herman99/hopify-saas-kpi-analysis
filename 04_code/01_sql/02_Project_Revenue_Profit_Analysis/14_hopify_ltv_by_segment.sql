/* 
==================================================================================================
📄 Filename     : 14_ltv_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : LTV by Segment with Benchmarks
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- LTV by Segment with Benchmarks
-- ===============================================================================================

WITH churn_rates AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id), 4) AS churn_rate
    FROM customers AS c
    LEFT JOIN churn_events AS ce ON c.customer_id = ce.customer_id
    GROUP BY c.customer_segment
),

ltv_by_segment AS (
    SELECT
        c.customer_segment,
        ROUND(AVG(o.total_amount), 2) AS avg_order_value,
        ROUND(AVG(order_counts.num_orders), 2) AS avg_orders_per_customer
    FROM customers AS c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN (
        SELECT customer_id, COUNT(*) AS num_orders
        FROM orders
        GROUP BY customer_id
    ) AS order_counts ON c.customer_id = order_counts.customer_id
    GROUP BY c.customer_segment
),

ltv_calculated AS (
    SELECT
        s.customer_segment,
        ROUND((s.avg_order_value * s.avg_orders_per_customer) / NULLIF(cr.churn_rate, 0), 2) AS estimated_ltv
    FROM ltv_by_segment AS s
    JOIN churn_rates AS cr ON s.customer_segment = cr.customer_segment
),

ltv_benchmarks AS (
    SELECT segment, target_value AS ltv_target
    FROM benchmarks
    WHERE metric_name = 'LTV Target'
)

SELECT 
    l.customer_segment,
    l.estimated_ltv,
    b.ltv_target,
    CASE 
        WHEN l.estimated_ltv >= b.ltv_target THEN 'Met Target'
        ELSE 'Below Target'
    END AS ltv_status
FROM 
    ltv_calculated AS l
LEFT JOIN 
    ltv_benchmarks AS b ON l.customer_segment = b.segment
ORDER BY 
    l.estimated_ltv DESC;