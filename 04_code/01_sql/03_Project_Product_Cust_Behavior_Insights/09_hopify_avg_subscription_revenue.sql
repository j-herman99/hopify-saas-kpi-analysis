/* 
==================================================================================================
📄 Filename     : 09_avg_subscription_revenue.sql
📅 Created On   : 2025-05-13
📝 Description  : Avg Subscription Revenue per Customer Segment
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Avg Subscription Revenue per Customer Segment
-- ===============================================================================================

SELECT 
    c.customer_segment AS "Customer Segment",
    ROUND(AVG(s.subscription_price), 2) AS "Avg Subscription Price",
    COUNT(DISTINCT s.customer_id) AS "Customers with Subscriptions"
	
FROM 
    subscriptions AS s
	
JOIN 
    customers AS c
	
    ON s.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Avg Subscription Price" DESC;