/* 
==================================================================================================
📄 Filename     : 01_top_product_category_summary.sql
📅 Created On   : 2025-05-13
📝 Description  : Executive Summary – Top Product Category by Revenue and AOV
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Executive Summary – Top Product Category by Revenue and AOV
-- ===============================================================================================

WITH category_revenue AS (
    
	SELECT
        p.category AS category,
        SUM(
            CASE
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0
                    THEN oi.quantity * p.price
                ELSE oi.subtotal
            END
        ) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders
    
	FROM order_items AS oi
    
	JOIN products AS p ON oi.product_id = p.product_id
    
	GROUP BY p.category
),
category_aov AS (

    SELECT
        category,
        ROUND(total_revenue * 1.0 / total_orders, 2) AS aov
		
    FROM 
		category_revenue
)
SELECT
    cr.category AS "Top Product Category",
    ROUND(cr.total_revenue, 2) AS "Total Revenue",
    ca.aov AS "Average Order Value (AOV)"

FROM 
	category_revenue AS cr

JOIN category_aov ca 
	ON cr.category = ca.category

ORDER BY cr.total_revenue DESC

LIMIT 1;