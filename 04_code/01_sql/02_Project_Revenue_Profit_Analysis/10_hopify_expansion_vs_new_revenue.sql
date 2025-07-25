/* 
==================================================================================================
📄 Filename     : 10_expansion_vs_new_revenue.sql
📅 Created On   : 2025-05-13
📝 Description  : Expansion vs New Revenue by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Expansion vs New Revenue by Segment
-- ===============================================================================================

WITH first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

-- Most recent complete month (formatted as YYYY-MM)
latest_full_month AS (
    SELECT strftime('%Y-%m', DATE('now', 'start of month', '-1 day')) AS order_month
)

SELECT 
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(CASE WHEN fo.first_order_date = o.order_date THEN o.total_amount ELSE 0 END), 2) AS "New Business Revenue",
    ROUND(SUM(CASE WHEN fo.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END), 2) AS "Expansion Revenue",
    ROUND(SUM(o.total_amount), 2) AS "Total Revenue",
    ROUND(
        SUM(CASE WHEN fo.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END) * 100.0 / SUM(o.total_amount), 
        2
    ) AS "Expansion % of Total"

FROM 
    orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN first_orders AS fo ON o.customer_id = fo.customer_id
JOIN latest_full_month AS lfm ON strftime('%Y-%m', o.order_date) = lfm.order_month

GROUP BY 
    "Month", c.customer_segment

ORDER BY 
    "Customer Segment";