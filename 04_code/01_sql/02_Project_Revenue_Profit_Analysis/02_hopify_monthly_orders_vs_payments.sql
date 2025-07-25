/* 
==================================================================================================
📄 Filename     : 02_monthly_orders_vs_payments.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Revenue by Orders vs Payments (Segmented)
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Revenue by Orders vs Payments (Segmented)
-- ===============================================================================================

WITH last_complete_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS last_month_end
),
monthly_orders AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment,
        SUM(o.total_amount) AS order_revenue
    FROM orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE o.order_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
    GROUP BY month, c.customer_segment
),
monthly_payments AS (
    SELECT
        strftime('%Y-%m', p.payment_date) AS month,
        c.customer_segment,
        SUM(p.payment_amount) AS collected_revenue
    FROM payments AS p
    JOIN customers AS c ON p.customer_id = c.customer_id
    WHERE p.success = 1 AND p.payment_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
    GROUP BY month, c.customer_segment
)
SELECT
    mo.month AS "Month",
    mo.customer_segment AS "Segment",
    ROUND(mo.order_revenue, 2) AS "Order Revenue",
    ROUND(mp.collected_revenue, 2) AS "Collected Revenue"
FROM monthly_orders AS mo
LEFT JOIN monthly_payments AS mp 
    ON mo.month = mp.month AND mo.customer_segment = mp.customer_segment
ORDER BY mo.month DESC, mo.customer_segment;