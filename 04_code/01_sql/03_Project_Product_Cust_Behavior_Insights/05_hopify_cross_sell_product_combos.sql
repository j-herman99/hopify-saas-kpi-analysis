/* 
==================================================================================================
📄 Filename     : 05_cross_sell_product_combos.sql
📅 Created On   : 2025-05-13
📝 Description  : Top Cross-Sell Product Combos by Segment
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Top Cross-Sell Product Combos by Segment
-- ===============================================================================================

SELECT 
    customer_segment AS "Customer Segment",
    CASE 
	
        WHEN cat1 < cat2 THEN cat1 || ' + ' || cat2
		
        ELSE cat2 || ' + ' || cat1
		
    END AS "Category Combo",
	
    COUNT(*) AS "Combo Frequency"
	
FROM (

    SELECT 
        o.order_id,
        c.customer_segment,
        MIN(p.category) AS cat1,
        MAX(p.category) AS cat2,
        COUNT(DISTINCT p.category) AS category_count
		
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
        o.order_id, c.customer_segment
		
    HAVING 
        category_count = 2
		
) AS two_cat_orders

GROUP BY 
    customer_segment, "Category Combo"
	
ORDER BY 
    customer_segment,
    "Combo Frequency" DESC;