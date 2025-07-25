/* 
==================================================================================================
📄 Filename     : 05_arpu_vs_target.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly ARPU Actuals vs ARPU Target by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Monthly ARPU Actuals vs ARPU Target by Segment
-- ===============================================================================================


WITH last_complete_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS last_month_end
),
monthly_arpu AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment,
        ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.customer_id), 2) AS arpu
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
    GROUP BY month, c.customer_segment
),
benchmarks_resolved AS (
    SELECT 
        segment, 
        metric_name, 
        target_value 
    FROM benchmarks
    WHERE metric_name = 'ARPU Target'
      AND target_period = 'monthly'
)
SELECT
    ma.month AS "Month",
    ma.customer_segment AS "Segment",
    ma.arpu AS "ARPU",
    br.target_value AS "ARPU Target",
    ROUND(ma.arpu - br.target_value, 2) AS "Absolute Variance",
    CASE 
        WHEN br.target_value > 0 THEN ROUND((ma.arpu - br.target_value) * 100.0 / br.target_value, 2)
        ELSE NULL
    END AS "Variance %",
    CASE 
        WHEN ma.arpu >= br.target_value THEN 'Above Target'
        ELSE 'Below Target'
    END AS "Target Status",
    CASE 
        WHEN ma.arpu >= br.target_value THEN 'Green'
        WHEN ma.arpu >= br.target_value * 0.90 THEN 'Yellow'
        ELSE 'Red'
    END AS "Performance Zone"
FROM monthly_arpu AS ma
LEFT JOIN benchmarks_resolved AS br 
    ON TRIM(LOWER(ma.customer_segment)) = TRIM(LOWER(br.segment))
ORDER BY ma.month DESC, ma.customer_segment;