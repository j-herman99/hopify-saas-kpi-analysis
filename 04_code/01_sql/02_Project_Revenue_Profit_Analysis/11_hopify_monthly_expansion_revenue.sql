/* 
==================================================================================================
📄 Filename     : 11_monthly_expansion_revenue.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Expansion Revenue by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Expansion Revenue by Segment
-- ===============================================================================================

WITH first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM 
        orders
    GROUP BY 
        customer_id
)

SELECT 
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(
        CASE 
            WHEN fo.first_order_date <> o.order_date THEN o.total_amount 
            ELSE 0 
        END
    ), 2) AS "Expansion Revenue"
	
FROM 
    orders AS o
JOIN 
    customers AS c ON o.customer_id = c.customer_id
JOIN 
    first_orders AS fo ON o.customer_id = fo.customer_id

-- ✅ Filter to exclude current partial month
WHERE 
    strftime('%Y-%m', o.order_date) < strftime('%Y-%m', 'now')

GROUP BY 
    "Month", c.customer_segment

ORDER BY 
    "Month" DESC, c.customer_segment;