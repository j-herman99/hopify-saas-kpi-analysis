/*
Created By: Jade Herman
Created On: 2025-05-13
Description:  Project 1 – Hopify Churn, Retention, and Support Ticket Analysis.

Includes:
- Executive churn summary vs benchmark
- Cohort churn and retention rates
- Milestone (M1, M3, M6, M12) retention by segment and cohort
- Support ticket activity vs churn risk

*/


-- --------------------------------------------------------------------------------------------------------------------------
--- 1. Executive Summary: Most Recent Churn Rate by Segment vs Benchmark
-----------------------------------------------------------------------------------------------------------------------------

WITH last_complete_month AS (
    SELECT 
        strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS latest_month,
        date(date('now', 'start of month', '-1 day'), 'start of month') AS month_start
),

monthly_churn AS (
    SELECT 
        strftime('%Y-%m', ce.churn_date) AS month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM churn_events ce
    JOIN customers c ON ce.customer_id = c.customer_id
    GROUP BY month, c.customer_segment
),

active_customers_base AS (
    SELECT 
        lm.latest_month AS month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM customers c
    JOIN last_complete_month lm
    LEFT JOIN churn_events ce ON c.customer_id = ce.customer_id
    WHERE c.signup_date < lm.month_start
      AND (ce.churn_date IS NULL OR date(ce.churn_date) >= lm.month_start)
    GROUP BY c.customer_segment
),

benchmarks_filtered AS (
    SELECT segment, target_value
    FROM benchmarks
    WHERE metric_name = 'Monthly Churn Target (%)'
),

support_summary AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(st.ticket_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_tickets_per_customer,
        ROUND(AVG(julianday(st.resolved_at) - julianday(st.created_at)), 2) AS avg_resolution_days
    FROM customers c
    LEFT JOIN support_tickets st ON c.customer_id = st.customer_id
    GROUP BY c.customer_segment
)

SELECT
    mc.month AS "Month",
    mc.customer_segment AS "Segment",
    mc.churned_customers AS "Churned Customers",
    ac.active_customers AS "Active Customers",
    ROUND(mc.churned_customers * 100.0 / ac.active_customers, 2) AS "Churn Rate %",
    ROUND((1.0 - mc.churned_customers * 1.0 / ac.active_customers) * 100, 2) AS "Retention %",
    bf.target_value AS "Benchmark %",
    ROUND(ROUND(mc.churned_customers * 100.0 / ac.active_customers, 2) - bf.target_value, 2) AS "Variance %",
    ss.avg_tickets_per_customer AS "Avg. Support Tickets",
    ss.avg_resolution_days AS "Avg. Resolution Days"
FROM 
    monthly_churn mc
JOIN last_complete_month lm ON mc.month = lm.latest_month
JOIN active_customers_base ac 
    ON mc.customer_segment = ac.customer_segment AND mc.month = ac.month
LEFT JOIN benchmarks_filtered bf 
    ON mc.customer_segment = bf.segment
LEFT JOIN support_summary ss 
    ON mc.customer_segment = ss.customer_segment
ORDER BY mc.customer_segment;




---------------------------------------------------------
--- 2. Churn by Signup Cohort Month
---------------------------------------------------------

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
	
--------------------------------------------------------------------------------------
--- 3. Monthly Churn Rate by Segment with Benchmark
--------------------------------------------------------------------------------------

WITH monthly_churn AS (
    SELECT 
        strftime('%Y-%m', DATE(ce.churn_date)) AS churn_month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM 
        churn_events AS ce
    JOIN customers AS c 
        ON ce.customer_id = c.customer_id
    GROUP BY 
        churn_month, c.customer_segment
),

monthly_active AS (
    SELECT 
        strftime('%Y-%m', DATE(ml.date)) AS active_month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM (
        SELECT DISTINCT date(strftime('%Y-%m', churn_date) || '-01') AS date
        FROM churn_events
        WHERE strftime('%Y-%m', churn_date) < strftime('%Y-%m', 'now')
    ) AS ml
    JOIN customers AS c
        ON c.signup_date < ml.date
    LEFT JOIN churn_events AS ce
        ON c.customer_id = ce.customer_id
    WHERE ce.churn_date IS NULL OR DATE(ce.churn_date) >= ml.date
    GROUP BY 
        active_month, c.customer_segment
),

benchmarks_resolved AS (
    SELECT 
        s.segment,
        COALESCE(b1.target_value, b2.target_value) AS target_value
    FROM 
        (SELECT DISTINCT customer_segment AS segment FROM customers) AS s
    LEFT JOIN benchmarks AS b1 
        ON b1.segment = s.segment AND b1.metric_name = 'Monthly Churn Target (%)'
    LEFT JOIN benchmarks AS b2 
        ON b2.segment = 'All Segments' AND b2.metric_name = 'Monthly Churn Target (%)'
)

SELECT
    mc.churn_month AS "Month",
    mc.customer_segment AS "Segment",
    mc.churned_customers AS "Churned Customers",
    ma.active_customers AS "Active Customers",
    ROUND(mc.churned_customers * 100.0 / ma.active_customers, 2) AS "Churn Rate %",
    b.target_value AS "Benchmark Churn Rate %",
    ROUND(ROUND(mc.churned_customers * 100.0 / ma.active_customers, 2) - b.target_value, 2) AS "Variance %"
FROM 
    monthly_churn AS mc
JOIN 
    monthly_active AS ma 
    ON mc.churn_month = ma.active_month 
    AND mc.customer_segment = ma.customer_segment
LEFT JOIN 
    benchmarks_resolved AS b 
    ON mc.customer_segment = b.segment
ORDER BY 
    mc.churn_month DESC, mc.customer_segment;


	
------------------------------------------------------------------------------------------------------
--- 4. Retention % by Cohort, Segment, Churn Month
------------------------------------------------------------------------------------------------------

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



-----------------------------------------------------------------------------------------------------------------------------
--- 5. Retention Summary: Month 1, 3, 6, 12 Retention % by Cohort and Segment
-----------------------------------------------------------------------------------------------------------------------------

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
	
-------------------------------------------------------------------------------------------------
---- 6. Segment-Level Retention Summary: M1, M3, M6, M12 %
-------------------------------------------------------------------------------------------------

WITH cohort_base AS (
    SELECT
        customer_id,
        customer_segment,
        julianday(signup_date) AS signup_jd
    FROM customers
),

months_since_signup AS (
    SELECT 1 AS month_offset UNION ALL 
    SELECT 3 UNION ALL 
    SELECT 6 UNION ALL 
    SELECT 12
),

active_customers_per_segment AS (
    SELECT
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
    GROUP BY cb.customer_segment, mss.month_offset
),

original_sizes AS (
    SELECT 
        customer_segment, 
        COUNT(DISTINCT customer_id) AS original_size 
    FROM customers 
    GROUP BY customer_segment
)

SELECT
    a.customer_segment AS "Segment",
    ROUND(MAX(CASE WHEN a.month_offset = 1 THEN a.remaining_customers * 1.0 / NULLIF(o.original_size, 0) * 100 END), 2) AS "Month 1 %",
    ROUND(MAX(CASE WHEN a.month_offset = 3 THEN a.remaining_customers * 1.0 / NULLIF(o.original_size, 0) * 100 END), 2) AS "Month 3 %",
    ROUND(MAX(CASE WHEN a.month_offset = 6 THEN a.remaining_customers * 1.0 / NULLIF(o.original_size, 0) * 100 END), 2) AS "Month 6 %",
    ROUND(MAX(CASE WHEN a.month_offset = 12 THEN a.remaining_customers * 1.0 / NULLIF(o.original_size, 0) * 100 END), 2) AS "Month 12 %"
FROM 
    active_customers_per_segment AS a
JOIN original_sizes AS o 
    ON a.customer_segment = o.customer_segment
GROUP BY a.customer_segment
ORDER BY a.customer_segment;

------------------------------------------------------------------------
--- 7. Retention Curve by Signup Cohort Month
------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------
---  8. Hopify Support Ticket Volume vs Churn Risk by Segment
-------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------
---End of File
------------------------------------------------------------------------
 


