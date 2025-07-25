/* 
==================================================================================================
📄 Filename     : 11_support_tickets_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Support Ticket Volume & Avg Resolution Time by Customer Segment
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Support Ticket Volume & Avg Resolution Time by Customer Segment
-- ===============================================================================================

---------------------------------------------------------------------------------------------------------------------
--- 11. Support Ticket Volume & Avg Resolution Time by Customer Segment
---------------------------------------------------------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(st.ticket_id) AS "Total Support Tickets",
	
    ROUND(AVG(
	
        JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)
		
    ), 2) AS "Avg Resolution Days"
	
FROM 
    support_tickets AS st
	
JOIN 
    customers AS c
    ON st.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Total Support Tickets" DESC;