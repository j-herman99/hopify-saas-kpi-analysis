/* 
==================================================================================================
📄 Filename     : 06_segment_behavior_summary.sql
📅 Created On   : 2025-05-13
📝 Description  : Segment Behavior Summary (Churn, AOV, Subscriptions, Support)
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Segment Behavior Summary (Churn, AOV, Subscriptions, Support)
-- ===============================================================================================

WITH churn_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(COUNT(DISTINCT ce.customer_id) * 1.0 / 
            (SELECT COUNT(*) 
             FROM customers c2 
             WHERE c2.customer_segment = c.customer_segment) * 100, 2
        ) AS churn_rate
    FROM 
        churn_events AS ce
    JOIN 
        customers AS c ON ce.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

subscription_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(AVG(s.subscription_price), 2) AS avg_subscription_price
    FROM 
        subscriptions AS s
    JOIN 
        customers AS c ON s.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

order_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
    FROM 
        orders AS o
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

support_stats AS (
    SELECT 
        c.customer_segment,
        COUNT(st.ticket_id) AS support_ticket_volume,
        ROUND(AVG(JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)), 2) AS avg_resolution_days
    FROM 
        support_tickets AS st
    JOIN 
        customers AS c ON st.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
)

SELECT 
    c.customer_segment AS "Customer Segment",
    COALESCE(ch.churn_rate, 0) AS "Churn Rate %",
    COALESCE(ss.avg_subscription_price, 0) AS "Avg Subscription Price",
    COALESCE(os.avg_order_value, 0) AS "Avg Order Value (AOV)",
    COALESCE(sps.support_ticket_volume, 0) AS "Total Support Tickets",
    COALESCE(sps.avg_resolution_days, 0) AS "Avg Resolution Days"
FROM 
    customers AS c
LEFT JOIN churn_stats AS ch ON c.customer_segment = ch.customer_segment
LEFT JOIN subscription_stats AS ss ON c.customer_segment = ss.customer_segment
LEFT JOIN order_stats AS os ON c.customer_segment = os.customer_segment
LEFT JOIN support_stats AS sps ON c.customer_segment = sps.customer_segment
GROUP BY 
    c.customer_segment
ORDER BY 
    c.customer_segment;