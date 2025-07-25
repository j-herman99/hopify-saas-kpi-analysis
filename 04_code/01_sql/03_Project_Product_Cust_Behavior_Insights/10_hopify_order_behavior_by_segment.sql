/* 
==================================================================================================
📄 Filename     : 10_order_behavior_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Order Behavior by Customer Segment
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Order Behavior by Customer Segment
-- ===============================================================================================

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(DISTINCT o.order_id) AS "Total Orders",
    COUNT(DISTINCT c.customer_id) AS "Total Customers",
    ROUND(COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS "Orders per Customer",
	
    ROUND(
	
        SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.order_id), 
        2
		
    ) AS "Avg Order Value (AOV)"
	
FROM 
    customers AS c
	
JOIN 
    orders AS o
    ON c.customer_id = o.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Orders per Customer" DESC;