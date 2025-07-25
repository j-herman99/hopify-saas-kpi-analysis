/* 
==================================================================================================
📄 Filename     : 13_monthly_active_customers_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Active Customers by Segment (Orders-based)
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Active Customers by Segment (Orders-based)
-- ===============================================================================================

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
)

SELECT
    strftime('%Y-%m', o.order_date) AS month,
    c.customer_segment,
    COUNT(DISTINCT o.customer_id) AS active_customers
	
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN last_full_month lf 
    ON strftime('%Y-%m', o.order_date) <= lf.max_month

GROUP BY
    month, c.customer_segment

ORDER BY 
    month DESC, c.customer_segment;