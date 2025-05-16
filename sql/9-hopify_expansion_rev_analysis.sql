/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Expansion Revenue Analysis

*/


--Revenue split by type and segment

SELECT 

    c.customer_segment,
    COUNT(DISTINCT o.customer_id) AS "Total Customers",
    SUM(CASE WHEN o_first.first_order_date = o.order_date THEN o.total_amount ELSE 0 END) AS "New Business Revenue",
    SUM(CASE WHEN o_first.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END) AS "Expansion Revenue",
    ROUND(
        100.0 * SUM(CASE WHEN o_first.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END) / 
        SUM(o.total_amount), 2
		
    ) AS "Expansion % of Total"
	
FROM 
	orders AS o

JOIN
	customers AS c 
		ON o.customer_id = c.customer_id

JOIN (

    SELECT
		customer_id, MIN(order_date) AS first_order_date
	
    FROM
		orders
	
    GROUP BY 
		customer_id
	
) AS o_first ON o.customer_id = o_first.customer_id

GROUP BY
	c.customer_segment
	
ORDER BY
	c.customer_segment;



--Identify Top Expansion Customers

SELECT 
    c.customer_id,
    c.customer_segment,
    c.name,
    COUNT(DISTINCT o.order_id) AS "Total Orders",
    ROUND(SUM(o.total_amount), 2) AS "Total Revenue",
    ROUND(SUM(CASE WHEN o_first.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END), 2) AS "Expansion Revenue"
	
FROM 
	orders AS o

JOIN
	customers AS c 
		ON o.customer_id = c.customer_id

JOIN (

    SELECT 
		customer_id, MIN(order_date) AS first_order_date
	
    FROM 
		orders
	
    GROUP BY 
		customer_id
	
) AS o_first ON o.customer_id = o_first.customer_id

GROUP BY
	c.customer_id

HAVING 
	"Total Orders" > 1

ORDER BY 
	"Expansion Revenue" DESC

LIMIT 20;



---Cross-sell behavior - Categories by repeat orders

SELECT 
    o.customer_id,
    COUNT(DISTINCT p.category) AS "Distinct Categories",
    GROUP_CONCAT(DISTINCT p.category) AS "Categories Purchased"
	
FROM orders AS o

JOIN order_items AS oi 
	ON o.order_id = oi.order_id

JOIN products AS p
ON oi.product_id = p.product_id

JOIN (

    SELECT 
		customer_id, MIN(order_date) AS first_order_date
		
    FROM 
		orders
		
    GROUP BY 
		customer_id
		
) AS o_first ON o.customer_id = o_first.customer_id

WHERE
	o.order_date <> o_first.first_order_date
	
GROUP BY 
	o.customer_id
	
ORDER BY 
	"Distinct Categories" DESC
	
LIMIT 20;



