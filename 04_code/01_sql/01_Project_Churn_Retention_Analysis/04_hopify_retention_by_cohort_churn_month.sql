/* 
==================================================================================================
📄 Filename     : 04_retention_by_cohort_churn_month.sql
📅 Created On   : 2025-05-13
📝 Description  : Retention % by Signup Cohort, Segment, and Churn Month
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 4. Retention % by Cohort, Segment, and Churn Month
-- ===============================================================================================

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort
    FROM customers
),

churned_customers AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        strftime('%Y-%m', c.signup_date) AS signup_cohort,
        strftime('%Y-%m', ce.churn_date) AS churn_month
    FROM
        churn_events AS ce
    JOIN customers AS c ON ce.customer_id = c.customer_id
),

cohort_sizes AS (
    SELECT
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS cohort_size
    FROM
        cohort_base
    GROUP BY
        signup_cohort, customer_segment
),

churn_by_month AS (
    SELECT
        signup_cohort,
        customer_segment,
        churn_month,
        COUNT(DISTINCT customer_id) AS churned_customers
    FROM
        churned_customers
    GROUP BY
        signup_cohort, customer_segment, churn_month
)

SELECT
    cbm.signup_cohort AS "Signup Cohort Month",
    cbm.customer_segment AS "Segment",
    cbm.churn_month AS "Churn Month",
    cs.cohort_size AS "Cohort Size",
    cbm.churned_customers AS "Churned Customers",
    ROUND((1.0 - cbm.churned_customers * 1.0 / cs.cohort_size) * 100, 2) AS "Retention %"
FROM
    churn_by_month AS cbm
JOIN
    cohort_sizes AS cs
    ON cbm.signup_cohort = cs.signup_cohort AND cbm.customer_segment = cs.customer_segment
ORDER BY
    cbm.signup_cohort DESC, cbm.churn_month DESC, cbm.customer_segment;
