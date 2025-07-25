/* 
==================================================================================================
📄 Filename     : 06_retention_milestones_by_segment.sql
📅 Created On   : 2025-05-13
📝 Description  : Segment-Level Retention Summary – Month 1, 3, 6, 12 Retention %
📊 Project      : Project 1 – Hopify Churn, Retention, and Support Ticket Analysis
==================================================================================================
*/

-- ===============================================================================================
-- 6. Segment-Level Retention Summary: M1, M3, M6, M12 %
-- ===============================================================================================

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