/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Support Ticket Volume vs Churn Risk

*/

--Churn Rate by Support Ticket Activity Group

WITH ticket_activity AS (

    SELECT 
        c.customer_id,
        COUNT(st.ticket_id) AS total_tickets
		
    FROM 
        customers AS c
		
    LEFT JOIN 
        support_tickets AS st
		
    ON c.customer_id = st.customer_id
	
    GROUP BY 
        c.customer_id
		
)
SELECT 
    CASE 
	
        WHEN ta.total_tickets >= 5 THEN 'High Support Volume (5+ Tickets)'
        WHEN ta.total_tickets BETWEEN 1 AND 4 THEN 'Low-Mid Support Volume (1-4 Tickets)'
        ELSE 'No Support Tickets'
		
    END AS "Support Ticket Group",
	
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers",
    COUNT(DISTINCT ta.customer_id) AS "Customers in Group",
    ROUND(COUNT(DISTINCT ce.customer_id) * 1.0 / COUNT(DISTINCT ta.customer_id) * 100, 2) AS "Churn Rate %"
	
FROM 
    ticket_activity AS ta
	
LEFT JOIN 
    churn_events AS ce
	
    ON ta.customer_id = ce.customer_id
	
GROUP BY 
    "Support Ticket Group"
	
ORDER BY 
    "Churn Rate %" DESC;

