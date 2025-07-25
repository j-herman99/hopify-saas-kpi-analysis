/* 
==================================================================================================
📄 Filename     : 16_arr_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Annual Recurring Revenue (ARR) by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Annual Recurring Revenue (ARR) by Segment
-- ===============================================================================================

WITH current_mrr AS (
    SELECT
        c.customer_segment,
        SUM(s.subscription_price) AS monthly_recurring_revenue
    FROM 
        subscriptions AS s
    JOIN 
        customers AS c ON s.customer_id = c.customer_id
    WHERE 
        s.status = 'active'
    GROUP BY 
        c.customer_segment
)

SELECT
    customer_segment AS "Segment",
    ROUND(monthly_recurring_revenue * 12, 2) AS "ARR"
FROM 
    current_mrr
ORDER BY 
    monthly_recurring_revenue DESC;