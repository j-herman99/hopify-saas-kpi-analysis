/* 
==================================================================================================
📄 Filename     : 02_top_categories_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Top Product Categories by Total Revenue & Segment
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Top Product Categories by Total Revenue & Segment
-- ===============================================================================================
	
SELECT
    c.customer_segment,
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue
FROM 
    order_items AS oi
JOIN 
    products AS p ON oi.product_id = p.product_id
JOIN 
    orders AS o ON oi.order_id = o.order_id
JOIN 
    customers AS c ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_segment, p.category
ORDER BY 
    c.customer_segment, total_revenue DESC;