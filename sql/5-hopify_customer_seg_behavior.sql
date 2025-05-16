/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Customer Segmentation Behavior

*/


--Churn Rate by Customer Segment


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

	
--Avg Subscription Revenue per Customer Segment

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
	
	
--Order Behavior by Customer Segment

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
	

--Support Ticket Volume & Avg Resolution Time by Customer Segment

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(st.ticket_id) AS "Total Support Tickets",
	
    ROUND(AVG(
	
        JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)
    ), 2) AS "Avg Resolution Days"
	
FROM 
    support_tickets AS st
	
JOIN 
    customers AS c
    ON st.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Total Support Tickets" DESC;
