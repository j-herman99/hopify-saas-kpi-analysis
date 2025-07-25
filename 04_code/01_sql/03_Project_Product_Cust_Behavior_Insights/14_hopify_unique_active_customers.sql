/* 
==================================================================================================
📄 Filename     : 14_unique_active_customers.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Unique Active Customers (Orders OR Payments)
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Unique Active Customers (Orders OR Payments)
-- ===============================================================================================

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
),

combined_activity AS (
    SELECT customer_id, strftime('%Y-%m', order_date) AS month 
    FROM orders

    UNION

    SELECT customer_id, strftime('%Y-%m', payment_date) AS month 
    FROM payments
    WHERE success = 1
)

SELECT
    ca.month,
    COUNT(DISTINCT ca.customer_id) AS unique_active_customers

FROM combined_activity ca
JOIN last_full_month lf ON ca.month <= lf.max_month

GROUP BY ca.month
ORDER BY ca.month DESC;