/* 
==================================================================================================
📄 Filename     : 09_nrr_grr_segment_over_time.sql
📅 Created On   : 2025-05-13
📝 Description  : NRR & GRR by Customer Segment Over Time
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- NRR & GRR by Customer Segment Over Time
-- ===============================================================================================

WITH base_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', s.start_date) AS month,
        SUM(s.subscription_price) AS starting_mrr
    FROM subscriptions s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE s.change_type = 'signup'
    GROUP BY c.customer_segment, month
),

churn_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', ce.churn_date) AS month,
        SUM(s.subscription_price) AS churned_mrr
    FROM churn_events ce
    JOIN subscriptions s ON ce.customer_id = s.customer_id
    JOIN customers c ON ce.customer_id = c.customer_id
    WHERE s.start_date < ce.churn_date
    GROUP BY c.customer_segment, month
),

expansion_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', s.start_date) AS month,
        SUM(s.subscription_price) AS expansion_mrr
    FROM subscriptions s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE s.change_type IN ('upgrade', 'reactivation')
    GROUP BY c.customer_segment, month
),

nrr_benchmarks AS (
    SELECT 
        LOWER(TRIM(segment)) AS segment_norm,
        target_value AS nrr_target
    FROM benchmarks
    WHERE TRIM(metric_name) = 'NRR Target (%)'
),

grr_benchmarks AS (
    SELECT 
        LOWER(TRIM(segment)) AS segment_norm,
        target_value AS grr_target
    FROM benchmarks
    WHERE TRIM(metric_name) = 'GRR Target (%)'
)

SELECT 
    bm.customer_segment AS "Customer Segment",
    bm.month AS "Month",
    ROUND(bm.starting_mrr, 2) AS "Starting MRR",
    ROUND(COALESCE(cm.churned_mrr, 0), 2) AS "Churned MRR",
    ROUND(COALESCE(em.expansion_mrr, 0), 2) AS "Expansion MRR",

    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0)) * 100.0 / bm.starting_mrr, 2) AS "GRR %",
    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0) + COALESCE(em.expansion_mrr, 0)) * 100.0 / bm.starting_mrr, 2) AS "NRR %",

    nb.nrr_target AS "NRR Target (%)",
    gb.grr_target AS "GRR Target (%)"

FROM base_mrr bm
LEFT JOIN churn_mrr cm 
    ON bm.customer_segment = cm.customer_segment AND bm.month = cm.month
LEFT JOIN expansion_mrr em 
    ON bm.customer_segment = em.customer_segment AND bm.month = em.month
LEFT JOIN nrr_benchmarks nb 
    ON LOWER(TRIM(bm.customer_segment)) = nb.segment_norm
LEFT JOIN grr_benchmarks gb 
    ON LOWER(TRIM(bm.customer_segment)) = gb.segment_norm

-- ✅ Only include completed months (up through April 2025)
WHERE bm.month <= '2025-04'

ORDER BY bm.month DESC, bm.customer_segment;