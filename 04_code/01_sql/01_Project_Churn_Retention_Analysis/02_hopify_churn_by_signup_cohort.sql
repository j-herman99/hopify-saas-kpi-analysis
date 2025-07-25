/* 
==================================================================================================
📄 Filename     : 02_churn_by_signup_cohort.sql
📅 Created On   : 2025-05-13
📝 Description  : Churn Count by Signup Cohort Month and Churn Month, grouped by Segment
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 2. Churn by Signup Cohort Month
-- ===============================================================================================

SELECT
    strftime('%Y-%m', c.signup_date) AS "Signup Cohort Month",
    strftime('%Y-%m', ce.churn_date) AS "Churn Month",
    c.customer_segment AS "Segment",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers"
FROM
    churn_events AS ce
JOIN
    customers AS c 
        ON ce.customer_id = c.customer_id
GROUP BY
    "Signup Cohort Month", "Churn Month", "Segment"
ORDER BY
    "Signup Cohort Month" DESC, "Churn Month" DESC, "Segment";
