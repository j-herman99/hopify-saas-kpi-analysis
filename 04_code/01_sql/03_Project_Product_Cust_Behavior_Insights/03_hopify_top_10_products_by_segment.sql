/* 
==================================================================================================
📄 Filename     : 03_top_10_products_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Top 10 Best-Selling Products by Segment & Total Revenue
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Top 10 Best-Selling Products by Segment & Total Revenue
-- ===============================================================================================

WITH product_revenue_by_segment AS (
    SELECT 
        c.customer_segment AS segment,
        p.name AS product_name,
        p.category AS product_category,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(
            CASE 
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0 
                    THEN oi.quantity * p.price
                ELSE oi.subtotal
            END
        ) AS total_revenue
    FROM 
        order_items AS oi
    JOIN 
        products AS p ON oi.product_id = p.product_id
    JOIN 
        orders AS o ON oi.order_id = o.order_id
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment, p.product_id
),

ranked_products AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY segment 
            ORDER BY total_revenue DESC
        ) AS rank_within_segment
    FROM 
        product_revenue_by_segment
)

SELECT 
    segment,
    product_name,
    product_category,
    total_orders,
    units_sold,
    printf('$%,.2f', total_revenue) AS total_revenue
FROM 
    ranked_products
WHERE 
    rank_within_segment <= 10
ORDER BY 
    segment, rank_within_segment;