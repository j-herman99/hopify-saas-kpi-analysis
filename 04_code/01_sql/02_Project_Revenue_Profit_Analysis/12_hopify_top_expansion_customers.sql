/* 
==================================================================================================
📄 Filename     : 12_top_expansion_customers.sql
📅 Created On   : 2025-05-13
📝 Description  : Top Expansion Customers
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Top Expansion Customers
-- ===============================================================================================

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