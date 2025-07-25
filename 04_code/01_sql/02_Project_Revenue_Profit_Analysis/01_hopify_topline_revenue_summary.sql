/* 
==================================================================================================
📄 Filename: 01_topline_revenue_summary.sql
📅 Created On:  2025-05-13
📝 Description: Top-Line Revenue Summary
📊 Project: Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Top-Line Revenue Summary
-- ===============================================================================================

-- Top-Line Revenue by Segment (Initial + Expansion Breakdown)

WITH customer_orders AS (
    SELECT 
        o.customer_id,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS initial_order_value
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_date >= date('now', 'start of month', '-12 months')
      AND o.order_date < date('now', 'start of month')
    GROUP BY o.customer_id
),

customer_payments AS (
    SELECT 
        p.customer_id,
        SUM(p.payment_amount) AS total_payments
    FROM payments p
    WHERE p.success = 1
      AND p.payment_date >= date('now', 'start of month', '-12 months')
      AND p.payment_date < date('now', 'start of month')
    GROUP BY p.customer_id
)

SELECT
    co.customer_segment AS segment,
    COUNT(DISTINCT co.customer_id) AS total_customers,
    SUM(co.total_orders) AS total_orders,
    ROUND(SUM(co.initial_order_value), 2) AS total_initial_order_value,
    ROUND(SUM(cp.total_payments), 2) AS total_collected_payments,
    ROUND(SUM(cp.total_payments) - SUM(co.initial_order_value), 2) AS expansion_revenue
FROM customer_orders co
LEFT JOIN customer_payments cp ON co.customer_id = cp.customer_id
GROUP BY co.customer_segment
ORDER BY expansion_revenue DESC;