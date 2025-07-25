/* 
==================================================================================================
📄 Filename     : 15_rolling_avg_active_customers.sql
📅 Created On   : 2025-05-13
📝 Description  : 3-Month Rolling Average: Active Customers from Orders
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- 3-Month Rolling Average: Active Customers from Orders
-- ===============================================================================================

--------------------------------------------------------------------------------------------------
--- 15. 3-Month Rolling Average: Active Customers from Orders (Completed Months Only)
--------------------------------------------------------------------------------------------------

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
),

monthly_orders AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    GROUP BY month
),

filtered_months AS (
    SELECT *
    FROM monthly_orders
    WHERE month <= (SELECT max_month FROM last_full_month)
),

rolling_avg AS (
    SELECT 
        month,
        active_customers,
        ROUND(
            AVG(active_customers) OVER (
                ORDER BY month 
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS rolling_avg_3mo
    FROM filtered_months
)

SELECT * 
FROM rolling_avg
ORDER BY month DESC;