/* 
==================================================================================================
📄 Filename     : 13_cross_sell_behavior.sql
📅 Created On   : 2025-05-13
📝 Description  : Cross-sell Behavior – Categories by Repeat Orders
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Cross-sell Behavior – Categories by Repeat Orders
-- ===============================================================================================

WITH last_complete_month AS (
    SELECT 
        date('now', 'start of month', '-1 day') AS last_month_end
),

first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

cross_sell_data AS (
    SELECT
        o.customer_id,
        c.customer_segment AS segment,
        COUNT(DISTINCT p.category) AS distinct_categories,
        GROUP_CONCAT(DISTINCT p.category) AS categories_purchased,
        SUM(oi.quantity) AS total_items_purchased,
        ROUND(SUM(oi.subtotal), 2) AS total_revenue
    FROM 
        orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    JOIN first_orders AS fo ON o.customer_id = fo.customer_id
    WHERE
        o.order_date <> fo.first_order_date
        AND o.order_date < (SELECT date(last_month_end, '+1 day') FROM last_complete_month)
    GROUP BY 
        o.customer_id, c.customer_segment
),

ranked_cross_sell AS (
    SELECT 
        cs.*,
        (
            SELECT COUNT(*) 
            FROM cross_sell_data AS inner_cs
            WHERE inner_cs.segment = cs.segment
              AND (
                  inner_cs.distinct_categories > cs.distinct_categories
                  OR (
                      inner_cs.distinct_categories = cs.distinct_categories
                      AND inner_cs.total_revenue > cs.total_revenue
                  )
              )
        ) + 1 AS rank
    FROM cross_sell_data AS cs
)

SELECT
    customer_id,
    segment AS "Segment",
    distinct_categories AS "Distinct Categories",
    categories_purchased AS "Categories Purchased",
    total_items_purchased AS "Total Items Purchased",
    total_revenue AS "Total Revenue"
FROM 
    ranked_cross_sell
WHERE 
    rank <= 10
ORDER BY 
    segment, rank;