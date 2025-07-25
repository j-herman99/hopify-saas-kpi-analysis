
/* 
==================================================================================================
📄 Filename     : 05_retention_milestones_by_cohort.sql
📅 Created On   : 2025-05-13
📝 Description  : Retention Summary – Month 1, 3, 6, 12 Retention % by Signup Cohort and Segment
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 5. Retention Summary: Month 1, 3, 6, 12 Retention % by Cohort and Segment
-- ===============================================================================================

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM 
        customers
),

months_of_interest AS (
    SELECT 1 AS month_offset UNION ALL 
    SELECT 3 UNION ALL 
    SELECT 6 UNION ALL 
    SELECT 12
),

cohort_activity AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        m.month_offset,
        cb.customer_id,
        CASE 
            WHEN ce.customer_id IS NULL THEN 1
            ELSE 0
        END AS is_retained
    FROM
        cohort_base AS cb
    JOIN
        months_of_interest AS m
    LEFT JOIN
        churn_events AS ce
            ON cb.customer_id = ce.customer_id
            AND julianday(ce.churn_date) <= (cb.signup_jd + (m.month_offset * 30))
),

cohort_summary AS (
    SELECT
        signup_cohort,
        customer_segment,
        month_offset,
        COUNT(DISTINCT customer_id) AS cohort_size,
        SUM(is_retained) AS retained_customers,
        ROUND(SUM(is_retained) * 1.0 / COUNT(DISTINCT customer_id), 4) AS retention_rate
    FROM
        cohort_activity
    GROUP BY
        signup_cohort, customer_segment, month_offset
),

pivoted_summary AS (
    SELECT
        signup_cohort,
        customer_segment,
        MAX(CASE WHEN month_offset = 1 THEN ROUND(retention_rate * 100, 2) END) AS "Month 1 Retention %",
        MAX(CASE WHEN month_offset = 3 THEN ROUND(retention_rate * 100, 2) END) AS "Month 3 Retention %",
        MAX(CASE WHEN month_offset = 6 THEN ROUND(retention_rate * 100, 2) END) AS "Month 6 Retention %",
        MAX(CASE WHEN month_offset = 12 THEN ROUND(retention_rate * 100, 2) END) AS "Month 12 Retention %"
    FROM
        cohort_summary
    GROUP BY
        signup_cohort, customer_segment
)

SELECT * FROM pivoted_summary
ORDER BY signup_cohort DESC, customer_segment;