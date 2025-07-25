/* 
==================================================================================================
📄 Filename     : 08_churn_rate_lifetime.sql
📅 Created On   : 2025-05-13
📝 Description  : Churn Rate by Customer Segment (Lifetime Snapshot)
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Churn Rate by Customer Segment (Lifetime Snapshot)
-- ===============================================================================================


SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers",
	
    (
        SELECT COUNT(*) 
        FROM customers AS c2 
        WHERE c2.customer_segment = c.customer_segment
    ) AS "Total Customers",
	
    ROUND(
        COUNT(DISTINCT ce.customer_id) * 1.0 / 
		
        (
            SELECT COUNT(*) 
            FROM customers AS c2 
            WHERE c2.customer_segment = c.customer_segment
			
        ) * 100, 2
		
    ) AS "Churn Rate %"
	
FROM 
    churn_events AS ce
	
JOIN 
    customers AS c
    ON ce.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Churn Rate %" DESC;