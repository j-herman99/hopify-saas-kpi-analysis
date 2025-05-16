/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Cohort Retention Analysis

*/


--Signup Cohort Size by Month

SELECT 
    strftime('%Y-%m', signup_date) AS "Signup Cohort Month",
    COUNT(DISTINCT customer_id) AS "Total Customers"
	
FROM 
    customers
	
GROUP BY 
    "Signup Cohort Month"
	
ORDER BY 
    "Signup Cohort Month" DESC;


--Churned Customers by Signup Cohort and Churn Month

SELECT 
    strftime('%Y-%m', c.signup_date) AS "Signup Cohort Month",
    strftime('%Y-%m', ce.churn_date) AS "Churn Month",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers"
	
FROM 
    churn_events ce
	
JOIN 
    customers c
    ON ce.customer_id = c.customer_id
	
GROUP BY 
    "Signup Cohort Month", "Churn Month"
	
ORDER BY 
    "Signup Cohort Month" DESC, "Churn Month" DESC;
	
	
-- Retention % by Signup Cohort and Months Since Signup (Self-Contained)

WITH cohort_base AS (
    SELECT 
        c.customer_id,
        strftime('%Y-%m', c.signup_date) AS signup_cohort,
        julianday(c.signup_date) AS signup_jd
    FROM 
        customers c
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3
    UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS remaining_customers
    FROM 
        cohort_base cb
    JOIN months_since_signup mss
    LEFT JOIN churn_events ce
        ON cb.customer_id = ce.customer_id
        AND julianday(ce.churn_date) <= cb.signup_jd + (mss.month_offset * 30)
    WHERE ce.churn_id IS NULL
    GROUP BY cb.signup_cohort, mss.month_offset
),

cohort_sizes AS (
    SELECT 
        signup_cohort,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_base
    GROUP BY signup_cohort
)

SELECT
    ac.signup_cohort AS "Signup Cohort Month",
    ac.month_offset AS "Months Since Signup",
    ac.remaining_customers AS "Remaining Active Customers",
    cs.total_customers AS "Total Cohort Customers",
    ROUND(ac.remaining_customers * 1.0 / cs.total_customers * 100, 2) AS "Retention %"
FROM 
    active_customers_per_cohort ac
JOIN 
    cohort_sizes cs
    ON ac.signup_cohort = cs.signup_cohort
ORDER BY 
    ac.signup_cohort DESC,
    ac.month_offset ASC;



