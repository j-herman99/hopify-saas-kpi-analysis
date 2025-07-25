/* 
==================================================================================================
📄 Filename     : 08_support_ticket_vs_churn_risk.sql
📅 Created On   : 2025-05-13
📝 Description  : Churn Risk by Support Ticket Volume Group (High / Low / None) by Segment
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 8. Hopify Support Ticket Volume vs Churn Risk by Segment
-- ===============================================================================================

WITH ticket_activity AS (

    SELECT 
        c.customer_id,
        c.customer_segment,
        COUNT(st.ticket_id) AS total_tickets
    FROM 
        customers AS c
    LEFT JOIN 
        support_tickets AS st ON c.customer_id = st.customer_id
    GROUP BY 
        c.customer_id, c.customer_segment
),

churn_analysis AS (

    SELECT 
        ta.customer_segment,
        CASE 
            WHEN ta.total_tickets >= 5 THEN 'High Support Volume (5+ Tickets)'
            WHEN ta.total_tickets BETWEEN 1 AND 4 THEN 'Low-Mid Support Volume (1-4 Tickets)'
            ELSE 'No Support Tickets'
        END AS support_group,
        COUNT(DISTINCT ce.customer_id) AS churned_customers,
        COUNT(DISTINCT ta.customer_id) AS total_customers
    FROM
        ticket_activity AS ta
    LEFT JOIN churn_events AS ce ON ta.customer_id = ce.customer_id
    GROUP BY 
        ta.customer_segment, support_group
),

churn_final AS (
    SELECT
        customer_segment AS "Segment",
        support_group AS "Support Ticket Group",
        churned_customers AS "Churned Customers",
        total_customers AS "Customers in Group",
        ROUND(churned_customers * 1.0 / total_customers * 100, 2) AS "Churn Rate %",
        ROUND(total_customers * 100.0 / (
            SELECT COUNT(*) 
            FROM ticket_activity 
            WHERE customer_segment = ca.customer_segment
        ), 2) AS "Customer % of Segment"
    FROM 
        churn_analysis AS ca
)

-- Combine segment support groups with All Customer reference
SELECT 
    *,
    CASE
        WHEN "Churn Rate %" >= 30 THEN 'High Risk'
        WHEN "Churn Rate %" BETWEEN 15 AND 29.99 THEN 'Moderate Risk'
        ELSE 'Low Risk'
    END AS "Churn Risk Level"
FROM churn_final

UNION ALL

-- Baseline: All Customers by Segment
SELECT 
    c.customer_segment AS "Segment",
    'All Customers' AS "Support Ticket Group",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers",
    COUNT(DISTINCT c.customer_id) AS "Customers in Group",
    ROUND(COUNT(DISTINCT ce.customer_id) * 1.0 / COUNT(DISTINCT c.customer_id) * 100, 2) AS "Churn Rate %",
    100.00 AS "Customer % of Segment",
    'Reference' AS "Churn Risk Level"
FROM customers AS c
LEFT JOIN churn_events AS ce ON c.customer_id = ce.customer_id
GROUP BY c.customer_segment

ORDER BY "Segment", "Support Ticket Group";