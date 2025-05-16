/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Churn Analysis

*/


--Monthly Churn Count

WITH monthly_churn AS (
    SELECT 
        strftime('%Y-%m', ce.churn_date) AS churn_month,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM 
        churn_events AS ce
    GROUP BY 
        churn_month
),
month_list AS (
    SELECT DISTINCT 
        date(strftime('%Y-%m', churn_date) || '-01') AS month_start
    FROM 
        churn_events
),
monthly_active AS (
    SELECT 
        strftime('%Y-%m', ml.month_start) AS active_month,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM 
        month_list AS ml
    JOIN 
        customers AS c
        ON c.signup_date < ml.month_start
    GROUP BY 
        active_month
)
SELECT
    mc.churn_month AS "Churn Month",
    mc.churned_customers AS "Churned Customers",
    ma.active_customers AS "Active Customers at Start of Month",
    ROUND((mc.churned_customers * 1.0 / ma.active_customers) * 100, 2) AS "Churn Rate %"
FROM 
    monthly_churn AS mc
JOIN 
    monthly_active AS ma
    ON mc.churn_month = ma.active_month
ORDER BY 
    "Churn Month" DESC;
	

-- Monthly Churn Rate (SaaS Best Practice)

WITH month_list AS (
    SELECT DISTINCT 
        strftime('%Y-%m', churn_date) AS month_start
    FROM 
        churn_events
    UNION
    SELECT DISTINCT 
        strftime('%Y-%m', signup_date)
    FROM customers
),

monthly_active AS (
    SELECT
        ml.month_start,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM
        month_list ml
    JOIN
        customers c
        ON c.signup_date < date(ml.month_start || '-01')
    GROUP BY
        ml.month_start
),

monthly_churned AS (
    SELECT
        strftime('%Y-%m', churn_date) AS churn_month,
        COUNT(DISTINCT customer_id) AS churned_customers
    FROM
        churn_events
    GROUP BY
        churn_month
)

SELECT
    ma.month_start AS "Month",
    ma.active_customers AS "Active Customers at Start of Month",
    COALESCE(mc.churned_customers, 0) AS "Churned Customers",
    ROUND(COALESCE(mc.churned_customers, 0) * 1.0 / ma.active_customers * 100, 2) AS "Churn Rate %"
FROM
    monthly_active ma
LEFT JOIN
    monthly_churned mc
    ON ma.month_start = mc.churn_month
ORDER BY
    ma.month_start DESC;	


--Churn by Customer Segment

SELECT
	strftime('%Y-%m', ce.churn_date) AS "Churn Month",
	c.customer_segment AS "Customer Segment"

FROM
	churn_events AS ce

JOIN
	customers AS  c
	ON ce.customer_id = c.customer_id
	
GROUP BY
	"Churn Month", "Customer Segment"
	
ORDER BY
	"Churn Month" DESC, "Customer Segment";
	
	
--Churn by Signup Cohort Month

SELECT
	strftime('%Y-%m', c.signup_date) AS "Signup Cohort Month",
	strftime('%Y-%m', ce.churn_date) AS "Churn Month",
	COUNT(DISTINCT ce.customer_id) AS "Churned Customers"

FROM
	churn_events AS ce
	
JOIN
	customers AS c
	ON ce.customer_id = c.customer_id
	
GROUP BY
	"Signup Cohort Month", "Churn Month"

ORDER BY
	"Signup Cohort Month" DESC, "Churn Month" DESC;
	
---Cohort Churn by Segment (Retention Decay Curve)

SELECT
    strftime('%Y-%m', c.signup_date) AS "Signup Cohort Month",
    c.customer_segment AS "Customer Segment",
    strftime('%Y-%m', ce.churn_date) AS "Churn Month",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers"
FROM
    churn_events ce
JOIN
    customers c
    ON ce.customer_id = c.customer_id
GROUP BY
    "Signup Cohort Month", "Customer Segment", "Churn Month"
ORDER BY
    "Signup Cohort Month" DESC, "Customer Segment", "Churn Month" DESC;

	
	
--Monthly Churn by Segment (SaaS Best Practice)

WITH month_list AS (
    SELECT DISTINCT 
        strftime('%Y-%m', churn_date) AS month_start
    FROM churn_events
    UNION
    SELECT DISTINCT 
        strftime('%Y-%m', signup_date)
    FROM customers
),

monthly_active AS (
    SELECT
        ml.month_start,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM
        month_list ml
    JOIN
        customers c
        ON c.signup_date < date(ml.month_start || '-01')
    GROUP BY
        ml.month_start, c.customer_segment
),

monthly_churned AS (
    SELECT
        strftime('%Y-%m', ce.churn_date) AS churn_month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM
        churn_events ce
    JOIN
        customers c
        ON ce.customer_id = c.customer_id
    GROUP BY
        churn_month, c.customer_segment
)

SELECT
    ma.month_start AS "Month",
    ma.customer_segment AS "Segment",
    ma.active_customers AS "Active Customers at Start of Month",
    COALESCE(mc.churned_customers, 0) AS "Churned Customers",
    ROUND(COALESCE(mc.churned_customers, 0) * 1.0 / ma.active_customers * 100, 2) AS "Churn Rate %"
	
FROM
    monthly_active AS ma
	
LEFT JOIN
    monthly_churned mc
    ON ma.month_start = mc.churn_month
    AND ma.customer_segment = mc.customer_segment
	
ORDER BY
    ma.month_start DESC,
    ma.customer_segment;
	
------
------Benchmark included

-- Monthly Churn Rate by Segment with Benchmark
WITH monthly_churn AS (
    SELECT 
        strftime('%Y-%m', churn_date) AS churn_month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM churn_events ce
    JOIN customers c ON ce.customer_id = c.customer_id
    GROUP BY churn_month, c.customer_segment
),
monthly_active AS (
    SELECT 
        strftime('%Y-%m', signup_date) AS active_month,
        customer_segment,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM customers
    GROUP BY active_month, customer_segment
)
SELECT
    mc.churn_month AS "Month",
    mc.customer_segment AS "Segment",
    mc.churned_customers AS "Churned Customers",
    ma.active_customers AS "Active Customers",
    ROUND(mc.churned_customers * 1.0 / ma.active_customers * 100, 2) AS "Churn Rate %",
    -- Benchmark pulled from benchmarks table
    b.target_value AS "Benchmark Churn Rate %",
    -- Optional variance calculation
    ROUND((mc.churned_customers * 1.0 / ma.active_customers * 100 - b.target_value), 2) AS "Variance %"
FROM
    monthly_churn mc
JOIN
    monthly_active ma ON mc.churn_month = ma.active_month AND mc.customer_segment = ma.customer_segment
LEFT JOIN
    benchmarks b ON mc.customer_segment = b.metric_category
    AND b.metric_name = 'Churn Rate %'
ORDER BY
    mc.churn_month DESC, mc.customer_segment;








-- Cohort Retention % by Segment (Corrected)

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
    SELECT 12
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        strftime('%Y-%m', date(cb.signup_jd, '+' || mss.month_offset || ' months')) AS active_month,
        COUNT(DISTINCT cb.customer_id) AS cohort_size
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.signup_cohort, cb.customer_segment, mss.month_offset
)

-- Output with % Retained by Cohort, Segment and Months Since Signup

SELECT
    ac.signup_cohort AS "Signup Cohort Month",
    ac.customer_segment AS "Customer Segment",
    ac.month_offset AS "Months Since Signup",
    ac.cohort_size AS "Remaining Active Customers",
    cs.total_customers AS "Original Cohort Size",
    ROUND(ac.cohort_size * 1.0 / cs.total_customers * 100, 2) AS "Retention %"
FROM
    active_customers_per_cohort ac
JOIN (
    SELECT
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM
        cohort_base
    GROUP BY
        signup_cohort, customer_segment
) cs
ON ac.signup_cohort = cs.signup_cohort AND ac.customer_segment = cs.customer_segment
ORDER BY
    ac.signup_cohort DESC,
    ac.customer_segment,
    ac.month_offset ASC;
	
-----

-- Pivoted Cohort Retention % by Segment (Month 0, Month 1... as columns)

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
    SELECT 12
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS cohort_size
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.signup_cohort, cb.customer_segment, mss.month_offset
),

cohort_sizes AS (
    SELECT
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM
        cohort_base
    GROUP BY
        signup_cohort, customer_segment
),

retention_calculated AS (
    SELECT
        ac.signup_cohort,
        ac.customer_segment,
        ac.month_offset,
        ac.cohort_size,
        cs.total_customers,
        ROUND(ac.cohort_size * 1.0 / cs.total_customers * 100, 2) AS retention_percent
    FROM
        active_customers_per_cohort ac
    JOIN
        cohort_sizes cs
        ON ac.signup_cohort = cs.signup_cohort AND ac.customer_segment = cs.customer_segment
)

-- Final Pivot Query using CASE WHEN to pivot months
SELECT
    signup_cohort AS "Signup Cohort Month",
    customer_segment AS "Customer Segment",
    MAX(CASE WHEN month_offset = 0 THEN retention_percent END) AS "Month 0 %",
    MAX(CASE WHEN month_offset = 1 THEN retention_percent END) AS "Month 1 %",
    MAX(CASE WHEN month_offset = 2 THEN retention_percent END) AS "Month 2 %",
    MAX(CASE WHEN month_offset = 3 THEN retention_percent END) AS "Month 3 %",
    MAX(CASE WHEN month_offset = 4 THEN retention_percent END) AS "Month 4 %",
    MAX(CASE WHEN month_offset = 5 THEN retention_percent END) AS "Month 5 %",
    MAX(CASE WHEN month_offset = 6 THEN retention_percent END) AS "Month 6 %",
    MAX(CASE WHEN month_offset = 7 THEN retention_percent END) AS "Month 7 %",
    MAX(CASE WHEN month_offset = 8 THEN retention_percent END) AS "Month 8 %",
    MAX(CASE WHEN month_offset = 9 THEN retention_percent END) AS "Month 9 %",
    MAX(CASE WHEN month_offset = 10 THEN retention_percent END) AS "Month 10 %",
    MAX(CASE WHEN month_offset = 11 THEN retention_percent END) AS "Month 11 %",
    MAX(CASE WHEN month_offset = 12 THEN retention_percent END) AS "Month 12 %"
FROM
    retention_calculated
GROUP BY
    signup_cohort,
    customer_segment
ORDER BY
    signup_cohort DESC,
    customer_segment;
	
---

-- Pivoted Cohort Raw Counts by Segment (Month 0, Month 1... as columns)

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
    SELECT 12
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS cohort_size
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.signup_cohort, cb.customer_segment, mss.month_offset
)

-- Final Pivot Query using CASE WHEN to pivot months
SELECT
    signup_cohort AS "Signup Cohort Month",
    customer_segment AS "Customer Segment",
    MAX(CASE WHEN month_offset = 0 THEN cohort_size END) AS "Month 0",
    MAX(CASE WHEN month_offset = 1 THEN cohort_size END) AS "Month 1",
    MAX(CASE WHEN month_offset = 2 THEN cohort_size END) AS "Month 2",
    MAX(CASE WHEN month_offset = 3 THEN cohort_size END) AS "Month 3",
    MAX(CASE WHEN month_offset = 4 THEN cohort_size END) AS "Month 4",
    MAX(CASE WHEN month_offset = 5 THEN cohort_size END) AS "Month 5",
    MAX(CASE WHEN month_offset = 6 THEN cohort_size END) AS "Month 6",
    MAX(CASE WHEN month_offset = 7 THEN cohort_size END) AS "Month 7",
    MAX(CASE WHEN month_offset = 8 THEN cohort_size END) AS "Month 8",
    MAX(CASE WHEN month_offset = 9 THEN cohort_size END) AS "Month 9",
    MAX(CASE WHEN month_offset = 10 THEN cohort_size END) AS "Month 10",
    MAX(CASE WHEN month_offset = 11 THEN cohort_size END) AS "Month 11",
    MAX(CASE WHEN month_offset = 12 THEN cohort_size END) AS "Month 12"
FROM
    active_customers_per_cohort
GROUP BY
    signup_cohort,
    customer_segment
ORDER BY
    signup_cohort DESC,
    customer_segment;
	
	
----

-- Combined Retention Curve (Counts + % side by side) by Cohort and Segment

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
    SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL
    SELECT 12
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS cohort_size
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.signup_cohort, cb.customer_segment, mss.month_offset
),

cohort_sizes AS (
    SELECT
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS original_size
    FROM cohort_base
    GROUP BY signup_cohort, customer_segment
)

SELECT
    ac.signup_cohort AS "Signup Cohort Month",
    ac.customer_segment AS "Customer Segment",
    ac.month_offset AS "Months Since Signup",
    ac.cohort_size AS "Remaining Customers",
    cs.original_size AS "Original Cohort Size",
    ROUND(ac.cohort_size * 1.0 / cs.original_size * 100, 2) AS "Retention %"
FROM
    active_customers_per_cohort ac
JOIN
    cohort_sizes cs
    ON ac.signup_cohort = cs.signup_cohort AND ac.customer_segment = cs.customer_segment
ORDER BY
    ac.signup_cohort DESC,
    ac.customer_segment,
    ac.month_offset ASC;


---Convert results into matrix-style heatmap via Excel or Power BI


-- Retention Summary: Month 1, 3, 6, 12 Retention % by Cohort and Segment

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        strftime('%Y-%m', signup_date) AS signup_cohort,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 1 AS month_offset UNION ALL SELECT 3 UNION ALL SELECT 6 UNION ALL SELECT 12
),

active_customers_per_cohort AS (
    SELECT
        cb.signup_cohort,
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS cohort_size
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.signup_cohort, cb.customer_segment, mss.month_offset
),

cohort_sizes AS (
    SELECT
        signup_cohort,
        customer_segment,
        COUNT(DISTINCT customer_id) AS original_size
    FROM cohort_base
    GROUP BY signup_cohort, customer_segment
)

SELECT
    ac.signup_cohort AS "Signup Cohort Month",
    ac.customer_segment AS "Customer Segment",
    MAX(CASE WHEN ac.month_offset = 1 THEN ROUND(ac.cohort_size * 1.0 / cs.original_size * 100, 2) END) AS "Month 1 Retention %",
    MAX(CASE WHEN ac.month_offset = 3 THEN ROUND(ac.cohort_size * 1.0 / cs.original_size * 100, 2) END) AS "Month 3 Retention %",
    MAX(CASE WHEN ac.month_offset = 6 THEN ROUND(ac.cohort_size * 1.0 / cs.original_size * 100, 2) END) AS "Month 6 Retention %",
    MAX(CASE WHEN ac.month_offset = 12 THEN ROUND(ac.cohort_size * 1.0 / cs.original_size * 100, 2) END) AS "Month 12 Retention %"
FROM
    active_customers_per_cohort ac
JOIN
    cohort_sizes cs
    ON ac.signup_cohort = cs.signup_cohort AND ac.customer_segment = cs.customer_segment
GROUP BY
    ac.signup_cohort,
    ac.customer_segment
ORDER BY
    ac.signup_cohort DESC,
    ac.customer_segment;

	
-- Segment-Level Aggregate Retention Curve (All Cohorts Combined)

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        signup_date,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 6 UNION ALL SELECT 12
),

active_customers_per_segment AS (
    SELECT
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS customers_still_active
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.customer_segment, mss.month_offset
),

original_sizes AS (
    SELECT
        customer_segment,
        COUNT(DISTINCT customer_id) AS original_size
    FROM customers
    GROUP BY customer_segment
)

SELECT
    ac.customer_segment AS "Customer Segment",
    ac.month_offset AS "Months Since Signup",
    ac.customers_still_active AS "Remaining Customers",
    os.original_size AS "Original Customers",
    ROUND(ac.customers_still_active * 1.0 / os.original_size * 100, 2) AS "Retention %"
FROM
    active_customers_per_segment ac
JOIN
    original_sizes os
    ON ac.customer_segment = os.customer_segment
ORDER BY
    ac.customer_segment,
    ac.month_offset ASC;

/*
✅ Interpretation:
Enterprise customers show very sticky retention over 12 months (~88.77%).

Mid-Market customers follow a slightly steeper but still healthy curve (~86.77% at 12 months).

SMB shows more aggressive decay (~65.75% at 12 months), which is expected given higher churn behavior for smaller customers.

This pattern is consistent with SaaS industry benchmarks, where:

Enterprise often retains 80%+ at 12 months.

Mid-Market might retain 75-85% at 12 months.

SMB might retain 50-70% at 12 months depending on product-market fit.

*/


---
WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        signup_date,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 0 AS month_offset UNION ALL SELECT 1 UNION ALL SELECT 3 UNION ALL SELECT 6 UNION ALL SELECT 12
),

active_customers_per_segment AS (
    SELECT
        cb.customer_segment,
        mss.month_offset,
        COUNT(DISTINCT cb.customer_id) AS customers_still_active
    FROM
        cohort_base cb
    JOIN
        months_since_signup mss
    LEFT JOIN
        churn_events ce
        ON cb.customer_id = ce.customer_id
           AND julianday(ce.churn_date) <= (cb.signup_jd + (mss.month_offset * 30))
    WHERE
        ce.churn_id IS NULL
    GROUP BY
        cb.customer_segment, mss.month_offset
),

original_sizes AS (
    SELECT
        customer_segment,
        COUNT(DISTINCT customer_id) AS original_size
    FROM customers
    GROUP BY customer_segment
)

SELECT
    ac.customer_segment AS "Customer Segment",
    ROUND(SUM(CASE WHEN ac.month_offset = 0 THEN ac.customers_still_active * 1.0 / os.original_size * 100 ELSE NULL END), 2) AS "Month 0 %",
    ROUND(SUM(CASE WHEN ac.month_offset = 1 THEN ac.customers_still_active * 1.0 / os.original_size * 100 ELSE NULL END), 2) AS "Month 1 %",
    ROUND(SUM(CASE WHEN ac.month_offset = 3 THEN ac.customers_still_active * 1.0 / os.original_size * 100 ELSE NULL END), 2) AS "Month 3 %",
    ROUND(SUM(CASE WHEN ac.month_offset = 6 THEN ac.customers_still_active * 1.0 / os.original_size * 100 ELSE NULL END), 2) AS "Month 6 %",
    ROUND(SUM(CASE WHEN ac.month_offset = 12 THEN ac.customers_still_active * 1.0 / os.original_size * 100 ELSE NULL END), 2) AS "Month 12 %"
FROM
    active_customers_per_segment ac
JOIN
    original_sizes os
    ON ac.customer_segment = os.customer_segment
GROUP BY
    ac.customer_segment
ORDER BY
    ac.customer_segment;
	

