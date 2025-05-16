/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Lifetime Value (LTV) by Segment

*/


--Estimated LTV by Segment (Simplified using ARPU and churn rate proxy)

WITH arpu AS (

    SELECT
        c.customer_segment,
        AVG(o.total_amount) AS avg_revenue_per_order,
        AVG(order_counts.num_orders) AS avg_orders_per_customer
		
    FROM 
		customers AS c
	
    JOIN orders o ON c.customer_id = o.customer_id
	
    JOIN (
	
        SELECT 
			customer_id, COUNT(*) AS num_orders
		
        FROM 
			orders
			
        GROUP BY 
			customer_id
			
    ) AS order_counts
	
    ON c.customer_id = order_counts.customer_id
    GROUP BY 
		c.customer_segment
),
churn_rates AS (

    SELECT
        c.customer_segment,
        ROUND( (COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id)), 4) AS churn_rate
		
    FROM
		customers AS c
		
    LEFT JOIN 
		churn_events AS ce 
			ON c.customer_id = ce.customer_id
			
    GROUP BY 
		c.customer_segment
		
)
SELECT

    a.customer_segment,
    ROUND(a.avg_revenue_per_order * a.avg_orders_per_customer, 2) AS arpu,
    cr.churn_rate,
	
    CASE 
	
        WHEN cr.churn_rate > 0 THEN ROUND((a.avg_revenue_per_order * a.avg_orders_per_customer) / cr.churn_rate, 2)
		
        ELSE NULL
		
    END AS estimated_ltv
	
FROM
	arpu AS a
	
JOIN churn_rates cr 
	ON a.customer_segment = cr.customer_segment
	
ORDER BY 
	estimated_ltv DESC;



--Estimated LTV per Customer (Segment-aware)

WITH churn_rates AS (

    SELECT
        c.customer_segment,
        ROUND( (COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id)), 4) AS churn_rate
		
    FROM 
		customers AS c
		
    LEFT JOIN 
		churn_events AS ce 
			ON c.customer_id = ce.customer_id
			
    GROUP BY 
		c.customer_segment
		
),
customer_orders AS (

    SELECT
        o.customer_id,
        c.customer_segment,
        c.name AS customer_name,
        COUNT(o.order_id) AS num_orders,
        AVG(o.total_amount) AS avg_order_value,
        SUM(o.total_amount) AS total_spend
		
    FROM 
	orders AS o
	
    JOIN 
		customers AS c 
			ON o.customer_id = c.customer_id
			
    GROUP BY 
		o.customer_id
)

SELECT
    co.customer_id,
    co.customer_segment,
    co.customer_name,
    co.num_orders,
    ROUND(co.avg_order_value, 2) AS avg_order_value,
    ROUND(co.total_spend, 2) AS total_spend,
    cr.churn_rate,
	
    CASE 
	
        WHEN cr.churn_rate > 0 THEN ROUND(co.total_spend / cr.churn_rate, 2)
		
        ELSE NULL
		
    END AS estimated_ltv
	
FROM 
	customer_orders AS co
	
JOIN 
	churn_rates AS cr
		ON co.customer_segment = cr.customer_segment
	
ORDER BY 
	estimated_ltv DESC
	
LIMIT 20;