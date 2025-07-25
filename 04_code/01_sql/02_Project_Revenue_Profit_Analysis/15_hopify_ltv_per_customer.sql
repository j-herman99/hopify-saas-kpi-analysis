/* 
==================================================================================================
📄 Filename     : 15_ltv_per_customer.sql
📅 Created On   : 2025-05-13
📝 Description  : Estimated LTV per Customer by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Estimated LTV per Customer by Segment
-- ===============================================================================================

WITH churn_rates AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id), 4) AS churn_rate
    FROM 
        customers AS c
    LEFT JOIN 
        churn_events AS ce ON c.customer_id = ce.customer_id
    GROUP BY 
        c.customer_segment
),

customer_orders AS (
    SELECT
        o.customer_id,
        c.customer_segment,
        c.name AS customer_name,
        COUNT(o.order_id) AS num_orders,
        AVG(o.total_amount) AS avg_order_value,
        SUM(o.total_amount) AS total_spend
    FROM 
        orders AS o
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        o.customer_id
),

ltv_base AS (
    SELECT
        co.customer_id,
        co.customer_segment,
        co.customer_name,
        co.num_orders,
        ROUND(co.avg_order_value, 2) AS avg_order_value,
        ROUND(co.total_spend, 2) AS total_spend,
        cr.churn_rate,
        CASE 
            WHEN cr.churn_rate > 0 THEN ROUND(co.total_spend / cr.churn_rate, 2)
            ELSE NULL
        END AS estimated_ltv
    FROM 
        customer_orders AS co
    JOIN 
        churn_rates AS cr ON co.customer_segment = cr.customer_segment
)

SELECT *
FROM ltv_base
ORDER BY customer_segment, estimated_ltv DESC;
