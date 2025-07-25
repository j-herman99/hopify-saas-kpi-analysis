/* 
==================================================================================================
📄 Filename     : 07_retention_curve_by_signup_month.sql
📅 Created On   : 2025-05-13
📝 Description  : Retention Curve by Signup Cohort – Month-over-Month Active Customer Trend
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 7. Retention Curve by Signup Cohort Month
-- ===============================================================================================

WITH cohort_base AS (
    SELECT 
        c.customer_id,
        c.customer_segment,
        strftime('%Y-%m', c.signup_date) AS signup_cohort,
        julianday(c.signup_date) AS signup_jd
    FROM customers AS c
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS remaining_customers
    FROM 
        cohort_base AS cb
    JOIN months_since_signup AS mss
    LEFT JOIN churn_events AS ce
        ON cb.customer_id = ce.customer_id
        AND julianday(ce.churn_date) <= cb.signup_jd + (mss.month_offset * 30)
    WHERE ce.churn_id IS NULL
    GROUP BY cb.signup_cohort, mss.month_offset
),

cohort_sizes AS (
    SELECT 
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_base
    GROUP BY signup_cohort
)

SELECT
    ac.signup_cohort AS "Signup Cohort Month",
    ac.customer_segment AS "Customer Segment",
    ac.month_offset AS "Months Since Signup",
    ac.remaining_customers AS "Remaining Active Customers",
    cs.total_customers AS "Total Cohort Customers",
    ROUND(ac.remaining_customers * 1.0 / NULLIF(cs.total_customers, 0) * 100, 2) AS "Retention %"
FROM 
    active_customers_per_cohort AS ac
JOIN cohort_sizes AS cs
    ON ac.signup_cohort = cs.signup_cohort
ORDER BY ac.signup_cohort DESC, ac.month_offset ASC;