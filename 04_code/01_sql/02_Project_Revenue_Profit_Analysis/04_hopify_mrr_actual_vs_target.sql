/* 
==================================================================================================
📄 Filename     : 04_mrr_actual_vs_target.sql
📅 Created On   : 2025-05-13
📝 Description  : MRR Actual vs. MRR Target
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- MRR Actual vs. MRR Target
-- ===============================================================================================

WITH monthly_mrr AS (
    SELECT
        strftime('%Y-%m', s.start_date) AS month,
        c.customer_segment AS segment,
        SUM(s.subscription_price) AS mrr
    FROM subscriptions s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE s.status = 'active'
      AND s.start_date < date('now', 'start of month')
    GROUP BY month, segment
),
mrr_targets AS (
    SELECT 
        segment, 
        target_value AS mrr_target
    FROM benchmarks
    WHERE metric_name = 'MRR Target'
      AND target_period = 'monthly' -- Optional: Only use if target period is tracked in database
)

SELECT
    m.month,
    m.segment,
    ROUND(m.mrr, 2) AS actual_mrr,
    t.mrr_target,
    ROUND(m.mrr - t.mrr_target, 2) AS mrr_variance,
    CASE 
        WHEN t.mrr_target > 0 THEN ROUND((m.mrr - t.mrr_target) * 100.0 / t.mrr_target, 2)
        ELSE NULL
    END AS mrr_variance_pct
FROM monthly_mrr m
LEFT JOIN mrr_targets t ON m.segment = t.segment
ORDER BY m.month DESC, m.segment;