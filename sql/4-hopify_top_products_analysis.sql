/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Top Product Categories by Revenue

*/


--Top Product Categories by Total Revenue (Safe Logic)

SELECT
	p.category AS "Product Category",
	COUNT(DISTINCT oi.order_id) AS "Total Orders",
	SUM(
		CASE
		
			WHEN oi.subtotal IS NULL OR oi.subtotal = 0
			
				THEN oi.quantity * p.price
				
			ELSE oi.subtotal
			
			END
			
		) AS "Total Revenue" 
				
FROM
	order_items AS oi
	
JOIN
	products AS p
	
GROUP BY
	p.category

ORDER BY
	"Total Revenue" DESC;
	
	
--Top 10 Best-Selling Products by Total Revenue

SELECT 
    p.name AS "Product Name",
    p.category AS "Product Category",
    COUNT(DISTINCT oi.order_id) AS "Total Orders",
    SUM(
	
        CASE 
		
            WHEN oi.subtotal IS NULL OR oi.subtotal = 0 
			
                THEN oi.quantity * p.price
				
            ELSE oi.subtotal
			
        END
		
    ) AS "Total Revenue"
	
FROM 
    order_items oi
	
JOIN 
    products p
    ON oi.product_id = p.product_id
	
GROUP BY 
    p.product_id
	
ORDER BY 
    "Total Revenue" DESC
	
LIMIT 10;


--Average Order Value (AOV) by Product Category

SELECT 
    p.category AS "Product Category",
    ROUND(
        SUM(
		
            CASE 
			
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0 
				
                    THEN oi.quantity * p.price
					
                ELSE oi.subtotal
				
            END
        ) * 1.0 / COUNT(DISTINCT oi.order_id), 2
		
    ) AS "Average Order Value (AOV)"
	
FROM 
    order_items AS oi
	
JOIN 
    products AS p
    ON oi.product_id = p.product_id
	
GROUP BY 
    p.category
	
ORDER BY 
    "Average Order Value (AOV)" DESC;


--Orders Containing Multiple Product Categories (Cross-Sell Insight)

SELECT 
    o.order_id AS "Order ID",
    c.customer_id AS "Customer ID",
    c.name AS "Customer Name",
    c.customer_segment AS "Customer Segment",
    COUNT(DISTINCT p.category) AS "Distinct Categories",
    GROUP_CONCAT(p.category, ', ') AS "Categories Included"
	
FROM 
    order_items AS oi
	
JOIN 
    orders AS o
    ON oi.order_id = o.order_id
	
JOIN 
    customers AS c
    ON o.customer_id = c.customer_id
	
JOIN 
    products AS p
    ON oi.product_id = p.product_id
	
GROUP BY 
    o.order_id, c.customer_id, c.name, c.customer_segment
	
HAVING 
    COUNT(DISTINCT p.category) > 1
	
ORDER BY 
    "Distinct Categories" DESC,
    o.order_id ASC
	
LIMIT 100;

--




