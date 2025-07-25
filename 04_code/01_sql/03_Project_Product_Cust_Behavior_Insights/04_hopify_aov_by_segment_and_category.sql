/* 
==================================================================================================
📄 Filename     : 04_aov_by_segment_and_category.sql
📅 Created On   : 2025-05-13
📝 Description  : Average Order Value (AOV) by Segment & Product Category
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Average Order Value (AOV) by Segment & Product Category
-- ===============================================================================================

SELECT 
    c.customer_segment AS "Segment",
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
    products AS p ON oi.product_id = p.product_id

JOIN 
    orders AS o ON oi.order_id = o.order_id

JOIN 
    customers AS c ON o.customer_id = c.customer_id

GROUP BY 
    c.customer_segment, p.category

ORDER BY 
    c.customer_segment, "Average Order Value (AOV)" DESC;