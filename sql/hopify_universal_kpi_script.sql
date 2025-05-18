


-- Universal KPI Pack Pattern (Smart Segment Fallback)

WITH monthly_metrics AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment,
        
        -- ARPU
        ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS arpu,
        
        -- NRR (simplified example using payments as proxy for retained revenue)
        ROUND(SUM(o.total_amount) * 1.0 / SUM(o.total_amount), 2) * 100 AS nrr_percent,  -- Placeholder for example only
        
        -- GRR (similar logic, but excludes expansion)
        ROUND(SUM(o.total_amount) * 1.0 / SUM(o.total_amount), 2) * 100 AS grr_percent,  -- Placeholder for example only
        
        -- Churn Rate % (from churn_events)
        ROUND(
            (SELECT COUNT(DISTINCT ce.customer_id) FROM churn_events ce
             WHERE ce.churn_date BETWEEN DATE(o.order_date, 'start of month') AND DATE(o.order_date, 'start of month', '+1 month')
             AND ce.customer_id IN (SELECT customer_id FROM customers WHERE customer_segment = c.customer_segment)
            ) * 100.0 / COUNT(DISTINCT c.customer_id), 2
        ) AS churn_rate_percent
        
    FROM
        orders o
    JOIN
        customers c ON o.customer_id = c.customer_id
    GROUP BY
        month, c.customer_segment
),

-- Smart Benchmarks Resolver Pattern (per metric)
benchmarks_universal AS (
    SELECT
        segment,
        metric_name,
        target_value
    FROM benchmarks
    WHERE segment != 'All Segments'
    
    UNION ALL
    
    SELECT
        'All Segments' AS segment,
        metric_name,
        target_value
    FROM benchmarks
),

-- Deduplicate to prefer segment-specific first
benchmarks_resolved AS (
    SELECT
        b.metric_name,
        b.segment,
        b.target_value
    FROM
        benchmarks_universal b
    WHERE
        NOT EXISTS (
            SELECT 1 FROM benchmarks_universal b2
            WHERE b2.metric_name = b.metric_name
              AND b2.segment != 'All Segments'
              AND b2.segment = b.segment
        )
)

SELECT
    m.month,
    m.customer_segment,
    
    -- ARPU
    m.arpu AS "Actual ARPU",
    (SELECT target_value FROM benchmarks_resolved WHERE metric_name = 'ARPU Target' AND (segment = m.customer_segment OR segment = 'All Segments') LIMIT 1) AS "Benchmark ARPU",
    
    -- Churn Rate %
    m.churn_rate_percent AS "Actual Churn Rate %",
    (SELECT target_value FROM benchmarks_resolved WHERE metric_name = 'Monthly Churn % Target' AND (segment = m.customer_segment OR segment = 'All Segments') LIMIT 1) AS "Benchmark Churn Rate %",
    
    -- NRR %
    m.nrr_percent AS "Actual NRR %",
    (SELECT target_value FROM benchmarks_resolved WHERE metric_name = 'NRR % Target' AND (segment = m.customer_segment OR segment = 'All Segments') LIMIT 1) AS "Benchmark NRR %",
    
    -- GRR %
    m.grr_percent AS "Actual GRR %",
    (SELECT target_value FROM benchmarks_resolved WHERE metric_name = 'GRR % Target' AND (segment = m.customer_segment OR segment = 'All Segments') LIMIT 1) AS "Benchmark GRR %"
    
FROM
    monthly_metrics m
ORDER BY
    m.month DESC,
    m.customer_segment;
