/* 
==================================================================================================
📄 Filename     : 12_recent_active_users.sql
📅 Created On   : 2025-05-13
📝 Description  : Most Recent Active Users: Orders vs. Payments
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Most Recent Active Users: Orders vs. Payments
-- ===============================================================================================

WITH orders_activity AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT customer_id) AS orders_active
    FROM orders
    GROUP BY month
),
payments_activity AS (
    SELECT
        strftime('%Y-%m', payment_date) AS month,
        COUNT(DISTINCT customer_id) AS payments_active
    FROM payments
    WHERE success = 1
    GROUP BY month
),
combined_activity AS (
    SELECT 
        o.month,
        o.orders_active,
        COALESCE(p.payments_active, 0) AS payments_active
    FROM orders_activity o
    LEFT JOIN payments_activity p ON o.month = p.month
),
ranked_activity AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY month DESC) AS rn
    FROM combined_activity
)
SELECT 
    curr.month AS "Month",
    curr.orders_active AS "Orders-Based Active",
    curr.payments_active AS "Payments-Based Active",
    prev.orders_active AS "Prev Month Orders",
    prev.payments_active AS "Prev Month Payments",
    ROUND((curr.orders_active - prev.orders_active) * 100.0 / prev.orders_active, 2) AS "Orders Change %",
    ROUND((curr.payments_active - prev.payments_active) * 100.0 / prev.payments_active, 2) AS "Payments Change %"
	
FROM 
	ranked_activity AS curr
	
LEFT JOIN ranked_activity AS prev 
	ON curr.rn = prev.rn - 1
	
WHERE 
	curr.rn = 1;