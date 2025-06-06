/*
Created By: Jade Herman
Created On: 2025-05-13

📊 Project 2: Revenue, Retention & Profitability Analysis
This consolidated SQL script includes:
- Top-line revenue
- MRR, ARPU, CAC, and Payback
- NRR & GRR (segment and cohort)
- Expansion revenue
- Lifetime Value (LTV) metrics
*/


------------------------------------------------
--- 1. Top-Line Revenue Summary
------------------------------------------------

-- Top-Line Revenue by Segment (Initial + Expansion Breakdown)

WITH customer_orders AS (
    SELECT 
        o.customer_id,
        c.customer_segment,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(o.total_amount) AS initial_order_value
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_date >= date('now', 'start of month', '-12 months')
      AND o.order_date < date('now', 'start of month')
    GROUP BY o.customer_id
),

customer_payments AS (
    SELECT 
        p.customer_id,
        SUM(p.payment_amount) AS total_payments
    FROM payments p
    WHERE p.success = 1
      AND p.payment_date >= date('now', 'start of month', '-12 months')
      AND p.payment_date < date('now', 'start of month')
    GROUP BY p.customer_id
)

SELECT
    co.customer_segment AS segment,
    COUNT(DISTINCT co.customer_id) AS total_customers,
    SUM(co.total_orders) AS total_orders,
    ROUND(SUM(co.initial_order_value), 2) AS total_initial_order_value,
    ROUND(SUM(cp.total_payments), 2) AS total_collected_payments,
    ROUND(SUM(cp.total_payments) - SUM(co.initial_order_value), 2) AS expansion_revenue
FROM customer_orders co
LEFT JOIN customer_payments cp ON co.customer_id = cp.customer_id
GROUP BY co.customer_segment
ORDER BY expansion_revenue DESC;


---------------------------------------------------------------------------------------------
--- 2. Monthly Revenue by Orders vs Payments (Segmented)
---------------------------------------------------------------------------------------------

WITH last_complete_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS last_month_end
),
monthly_orders AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment,
        SUM(o.total_amount) AS order_revenue
    FROM orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    WHERE o.order_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
    GROUP BY month, c.customer_segment
),
monthly_payments AS (
    SELECT
        strftime('%Y-%m', p.payment_date) AS month,
        c.customer_segment,
        SUM(p.payment_amount) AS collected_revenue
    FROM payments AS p
    JOIN customers AS c ON p.customer_id = c.customer_id
    WHERE p.success = 1 AND p.payment_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
    GROUP BY month, c.customer_segment
)
SELECT
    mo.month AS "Month",
    mo.customer_segment AS "Segment",
    ROUND(mo.order_revenue, 2) AS "Order Revenue",
    ROUND(mp.collected_revenue, 2) AS "Collected Revenue"
FROM monthly_orders AS mo
LEFT JOIN monthly_payments AS mp 
    ON mo.month = mp.month AND mo.customer_segment = mp.customer_segment
ORDER BY mo.month DESC, mo.customer_segment;


------------------------------------------------------------------------------------------------------
-- 3. Monthly Revenue by Product Category (Pivoted by Segment)
------------------------------------------------------------------------------------------------------

WITH last_complete_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS last_month_end
)
SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Segment",
    ROUND(SUM(CASE WHEN p.category = 'POS Hardware & Software' THEN oi.subtotal ELSE 0 END), 2) AS "POS",
    ROUND(SUM(CASE WHEN p.category = 'Payments & Finance' THEN oi.subtotal ELSE 0 END), 2) AS "Payments",
    ROUND(SUM(CASE WHEN p.category = 'Financial Services' THEN oi.subtotal ELSE 0 END), 2) AS "Finance",
    ROUND(SUM(CASE WHEN p.category = 'Apps & Integrations' THEN oi.subtotal ELSE 0 END), 2) AS "Apps",
    ROUND(SUM(CASE WHEN p.category = 'Storefront Tools' THEN oi.subtotal ELSE 0 END), 2) AS "Storefront",
    ROUND(SUM(CASE WHEN p.category = 'Marketing & Growth' THEN oi.subtotal ELSE 0 END), 2) AS "Marketing",
    ROUND(SUM(CASE WHEN p.category = 'Logistics & Shipping' THEN oi.subtotal ELSE 0 END), 2) AS "Logistics"
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
WHERE o.order_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
GROUP BY "Month", c.customer_segment
ORDER BY "Month" DESC, c.customer_segment;

--------------------------------------------------
-- 4. MRR Actual vs. MRR Target 
--------------------------------------------------

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



---------------------------------------------------------------------------------------------------
-- 5. Monthly ARPU Actuals vs ARPU Target by Segment
---------------------------------------------------------------------------------------------------

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

---------------------------------------------------------------------
-- 6.  CAC & CAC Payback Period by Segment 
---------------------------------------------------------------------

WITH new_customers AS (
    SELECT
        strftime('%Y-%m', signup_date) AS month,
        customer_segment AS segment,
        COUNT(customer_id) AS new_customers
    FROM customers
    WHERE signup_date < date('now', 'start of month')
    GROUP BY month, segment
),

segment_monthly_spend AS (
    SELECT
        segment,
        month,
        SUM(monthly_budget) AS monthly_marketing_spend
    FROM marketing_spend
    GROUP BY segment, month
),

cac_data AS (
    SELECT
        nc.month,
        nc.segment,
        nc.new_customers,
        sms.monthly_marketing_spend,
        CASE 
          WHEN nc.new_customers > 0 THEN ROUND(sms.monthly_marketing_spend / nc.new_customers, 2)
          ELSE NULL
        END AS cac
    FROM new_customers nc
    JOIN segment_monthly_spend sms
      ON nc.segment = sms.segment AND nc.month = sms.month
),

arpu_data AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment AS segment,
        ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.customer_id), 2) AS arpu
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_date < date('now', 'start of month')
    GROUP BY month, segment
)

SELECT
    a.month,
    a.segment,
    a.arpu,
    c.cac,
    ROUND(c.cac / a.arpu, 2) AS cac_payback_months,
    CASE
        WHEN ROUND(c.cac / a.arpu, 2) < 1 THEN 'Excellent (<1 mo)'
        WHEN ROUND(c.cac / a.arpu, 2) < 3 THEN 'Strong (1–3 mo)'
        WHEN ROUND(c.cac / a.arpu, 2) < 6 THEN 'Moderate (3–6 mo)'
        ELSE 'High Risk (>6 mo)'
    END AS payback_category
FROM arpu_data a
JOIN cac_data c ON a.month = c.month AND a.segment = c.segment
ORDER BY a.month DESC, a.segment;


------------------------------------------------------------------------------
--- 7. Most Recent Month NRR & GRR by Segment
------------------------------------------------------------------------------

WITH base_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', s.start_date) AS month,
        SUM(s.subscription_price) AS starting_mrr
    FROM subscriptions s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE s.change_type IN ('signup', 'upgrade', 'reactivation')
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
    SELECT segment, target_value AS nrr_target
    FROM benchmarks
    WHERE REPLACE(metric_name, '  ', ' ') LIKE 'NRR%Target%'
),

grr_benchmarks AS (
    SELECT segment, target_value AS grr_target
    FROM benchmarks
    WHERE REPLACE(metric_name, '  ', ' ') LIKE 'GRR%Target%'
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
    gb.grr_target AS "GRR Target (%)",

    CASE 
        WHEN ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0) + COALESCE(em.expansion_mrr, 0)) * 100.0 / bm.starting_mrr, 2) >= nb.nrr_target 
        THEN 'Met Target' ELSE 'Below Target' 
    END AS "NRR Target Status",

    CASE 
        WHEN ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0)) * 100.0 / bm.starting_mrr, 2) >= gb.grr_target 
        THEN 'Met Target' ELSE 'Below Target' 
    END AS "GRR Target Status"

FROM base_mrr bm
LEFT JOIN churn_mrr cm 
    ON bm.customer_segment = cm.customer_segment AND bm.month = cm.month
LEFT JOIN expansion_mrr em 
    ON bm.customer_segment = em.customer_segment AND bm.month = em.month
LEFT JOIN nrr_benchmarks nb 
    ON bm.customer_segment = nb.segment
LEFT JOIN grr_benchmarks gb 
    ON bm.customer_segment = gb.segment
WHERE bm.month = '2025-04'
ORDER BY bm.customer_segment;



---------------------------------------------------------------------
--- 8. Monthly NRR & GRR by Signup Cohort
---------------------------------------------------------------------

WITH latest_month AS (
    SELECT MAX(strftime('%Y-%m', start_date)) AS max_month
    FROM subscriptions
    WHERE start_date < date('now', 'start of month')
),

cohort_base AS (
    SELECT 
        s.customer_id,
        strftime('%Y-%m', s.start_date) AS cohort_month,
        s.subscription_price AS start_mrr
    FROM subscriptions s
    WHERE s.change_type = 'signup'
),

churned_revenue AS (
    SELECT 
        s.customer_id,
        SUM(s.subscription_price) AS churned_mrr
    FROM subscriptions s
    JOIN churn_events ce ON s.customer_id = ce.customer_id
    WHERE s.change_type = 'signup' AND s.start_date < ce.churn_date
    GROUP BY s.customer_id
),

expansion_revenue AS (
    SELECT 
        s.customer_id,
        SUM(s.subscription_price) AS expansion_mrr
    FROM subscriptions s
    WHERE s.change_type IN ('upgrade', 'reactivation')
    GROUP BY s.customer_id
)

SELECT 
    cb.cohort_month AS "Cohort Month",
    ROUND(SUM(cb.start_mrr), 2) AS "Starting MRR",
    ROUND(SUM(COALESCE(cr.churned_mrr, 0)), 2) AS "Churned MRR",
    ROUND(SUM(COALESCE(er.expansion_mrr, 0)), 2) AS "Expansion MRR",

    ROUND(
        (SUM(cb.start_mrr) - SUM(COALESCE(cr.churned_mrr, 0))) * 100.0 / SUM(cb.start_mrr), 2
    ) AS "Gross Revenue Retention %",
    
    ROUND(
        (SUM(cb.start_mrr) - SUM(COALESCE(cr.churned_mrr, 0)) + SUM(COALESCE(er.expansion_mrr, 0))) * 100.0 / SUM(cb.start_mrr), 2
    ) AS "Net Revenue Retention %"

FROM cohort_base cb
JOIN latest_month lm ON cb.cohort_month <= lm.max_month
LEFT JOIN churned_revenue cr ON cb.customer_id = cr.customer_id
LEFT JOIN expansion_revenue er ON cb.customer_id = er.customer_id
GROUP BY cb.cohort_month
ORDER BY cb.cohort_month DESC;


-------------------------------------------------------------------------------
--- 9. NRR & GRR by Customer Segment Over Time
-------------------------------------------------------------------------------

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


------------------------------------------------------------------------------------------------------------
--- 10.  Expansion vs New Revenue by Segment (Most Recent Month)
------------------------------------------------------------------------------------------------------------

WITH first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

-- Most recent complete month (formatted as YYYY-MM)
latest_full_month AS (
    SELECT strftime('%Y-%m', DATE('now', 'start of month', '-1 day')) AS order_month
)

SELECT 
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(CASE WHEN fo.first_order_date = o.order_date THEN o.total_amount ELSE 0 END), 2) AS "New Business Revenue",
    ROUND(SUM(CASE WHEN fo.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END), 2) AS "Expansion Revenue",
    ROUND(SUM(o.total_amount), 2) AS "Total Revenue",
    ROUND(
        SUM(CASE WHEN fo.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END) * 100.0 / SUM(o.total_amount), 
        2
    ) AS "Expansion % of Total"

FROM 
    orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN first_orders AS fo ON o.customer_id = fo.customer_id
JOIN latest_full_month AS lfm ON strftime('%Y-%m', o.order_date) = lfm.order_month

GROUP BY 
    "Month", c.customer_segment

ORDER BY 
    "Customer Segment";

	
--------------------------------------------------------------------------
--- 11. Monthly Expansion Revenue by Segment
--------------------------------------------------------------------------

WITH first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM 
        orders
    GROUP BY 
        customer_id
)

SELECT 
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(
        CASE 
            WHEN fo.first_order_date <> o.order_date THEN o.total_amount 
            ELSE 0 
        END
    ), 2) AS "Expansion Revenue"
	
FROM 
    orders AS o
JOIN 
    customers AS c ON o.customer_id = c.customer_id
JOIN 
    first_orders AS fo ON o.customer_id = fo.customer_id

-- ✅ Filter to exclude current partial month
WHERE 
    strftime('%Y-%m', o.order_date) < strftime('%Y-%m', 'now')

GROUP BY 
    "Month", c.customer_segment

ORDER BY 
    "Month" DESC, c.customer_segment;


----------------------------------------------------
--- 12. Top Expansion Customers
---------------------------------------------------

SELECT 
    c.customer_id,
    c.customer_segment,
    c.name,
    COUNT(DISTINCT o.order_id) AS "Total Orders",
    ROUND(SUM(o.total_amount), 2) AS "Total Revenue",
    ROUND(SUM(CASE WHEN o_first.first_order_date <> o.order_date THEN o.total_amount ELSE 0 END), 2) AS "Expansion Revenue"
	
FROM 
	orders AS o

JOIN
	customers AS c 
		ON o.customer_id = c.customer_id

JOIN (

    SELECT 
		customer_id, MIN(order_date) AS first_order_date
	
    FROM 
		orders
	
    GROUP BY 
		customer_id
	
) AS o_first ON o.customer_id = o_first.customer_id

GROUP BY
	c.customer_id

HAVING 
	"Total Orders" > 1

ORDER BY 
	"Expansion Revenue" DESC

LIMIT 20;


---------------------------------------------------------------------------------------
--- 13. Cross-sell behavior - Categories by repeat orders
---------------------------------------------------------------------------------------

WITH last_complete_month AS (
    SELECT 
        date('now', 'start of month', '-1 day') AS last_month_end
),

first_orders AS (
    SELECT 
        customer_id, 
        MIN(order_date) AS first_order_date
    FROM orders
    GROUP BY customer_id
),

cross_sell_data AS (
    SELECT
        o.customer_id,
        c.customer_segment AS segment,
        COUNT(DISTINCT p.category) AS distinct_categories,
        GROUP_CONCAT(DISTINCT p.category) AS categories_purchased,
        SUM(oi.quantity) AS total_items_purchased,
        ROUND(SUM(oi.subtotal), 2) AS total_revenue
    FROM 
        orders AS o
    JOIN customers AS c ON o.customer_id = c.customer_id
    JOIN order_items AS oi ON o.order_id = oi.order_id
    JOIN products AS p ON oi.product_id = p.product_id
    JOIN first_orders AS fo ON o.customer_id = fo.customer_id
    WHERE
        o.order_date <> fo.first_order_date
        AND o.order_date < (SELECT date(last_month_end, '+1 day') FROM last_complete_month)
    GROUP BY 
        o.customer_id, c.customer_segment
),

ranked_cross_sell AS (
    SELECT 
        cs.*,
        (
            SELECT COUNT(*) 
            FROM cross_sell_data AS inner_cs
            WHERE inner_cs.segment = cs.segment
              AND (
                  inner_cs.distinct_categories > cs.distinct_categories
                  OR (
                      inner_cs.distinct_categories = cs.distinct_categories
                      AND inner_cs.total_revenue > cs.total_revenue
                  )
              )
        ) + 1 AS rank
    FROM cross_sell_data AS cs
)

SELECT
    customer_id,
    segment AS "Segment",
    distinct_categories AS "Distinct Categories",
    categories_purchased AS "Categories Purchased",
    total_items_purchased AS "Total Items Purchased",
    total_revenue AS "Total Revenue"
FROM 
    ranked_cross_sell
WHERE 
    rank <= 10
ORDER BY 
    segment, rank;
	
	
----------------------------------------------------------------
--- 14. LTV by Segment with Benchmarks
----------------------------------------------------------------

WITH churn_rates AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id), 4) AS churn_rate
    FROM customers AS c
    LEFT JOIN churn_events AS ce ON c.customer_id = ce.customer_id
    GROUP BY c.customer_segment
),

ltv_by_segment AS (
    SELECT
        c.customer_segment,
        ROUND(AVG(o.total_amount), 2) AS avg_order_value,
        ROUND(AVG(order_counts.num_orders), 2) AS avg_orders_per_customer
    FROM customers AS c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN (
        SELECT customer_id, COUNT(*) AS num_orders
        FROM orders
        GROUP BY customer_id
    ) AS order_counts ON c.customer_id = order_counts.customer_id
    GROUP BY c.customer_segment
),

ltv_calculated AS (
    SELECT
        s.customer_segment,
        ROUND((s.avg_order_value * s.avg_orders_per_customer) / NULLIF(cr.churn_rate, 0), 2) AS estimated_ltv
    FROM ltv_by_segment AS s
    JOIN churn_rates AS cr ON s.customer_segment = cr.customer_segment
),

ltv_benchmarks AS (
    SELECT segment, target_value AS ltv_target
    FROM benchmarks
    WHERE metric_name = 'LTV Target'
)

SELECT 
    l.customer_segment,
    l.estimated_ltv,
    b.ltv_target,
    CASE 
        WHEN l.estimated_ltv >= b.ltv_target THEN 'Met Target'
        ELSE 'Below Target'
    END AS ltv_status
FROM 
    ltv_calculated AS l
LEFT JOIN 
    ltv_benchmarks AS b ON l.customer_segment = b.segment
ORDER BY 
    l.estimated_ltv DESC;


---------------------------------------------------------------------------
--- 15. Estimated LTV per Customer by Segment
--------------------------------------------------------------------------

WITH churn_rates AS (
    SELECT
        c.customer_segment,
        ROUND(COUNT(ce.churn_id) * 1.0 / COUNT(DISTINCT c.customer_id), 4) AS churn_rate
    FROM 
        customers AS c
    LEFT JOIN 
        churn_events AS ce ON c.customer_id = ce.customer_id
    GROUP BY 
        c.customer_segment
),

customer_orders AS (
    SELECT
        o.customer_id,
        c.customer_segment,
        c.name AS customer_name,
        COUNT(o.order_id) AS num_orders,
        AVG(o.total_amount) AS avg_order_value,
        SUM(o.total_amount) AS total_spend
    FROM 
        orders AS o
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        o.customer_id
),

ltv_base AS (
    SELECT
        co.customer_id,
        co.customer_segment,
        co.customer_name,
        co.num_orders,
        ROUND(co.avg_order_value, 2) AS avg_order_value,
        ROUND(co.total_spend, 2) AS total_spend,
        cr.churn_rate,
        CASE 
            WHEN cr.churn_rate > 0 THEN ROUND(co.total_spend / cr.churn_rate, 2)
            ELSE NULL
        END AS estimated_ltv
    FROM 
        customer_orders AS co
    JOIN 
        churn_rates AS cr ON co.customer_segment = cr.customer_segment
)

SELECT *
FROM ltv_base
ORDER BY customer_segment, estimated_ltv DESC;

------------------------------------------------------------------------------------
--- 16. Annual Recurring Revenue (ARR) by Segment
-----------------------------------------------------------------------------------

WITH current_mrr AS (
    SELECT
        c.customer_segment,
        SUM(s.subscription_price) AS monthly_recurring_revenue
    FROM 
        subscriptions AS s
    JOIN 
        customers AS c ON s.customer_id = c.customer_id
    WHERE 
        s.status = 'active'
    GROUP BY 
        c.customer_segment
)

SELECT
    customer_segment AS "Segment",
    ROUND(monthly_recurring_revenue * 12, 2) AS "ARR"
FROM 
    current_mrr
ORDER BY 
    monthly_recurring_revenue DESC;

	
--------------------------------------------------------------
--- END OF FILE
--------------------------------------------------------------

SELECT
  COUNT(*) AS total_payments,
  COUNT(DISTINCT p.customer_id) AS paying_customers,
  COUNT(DISTINCT c.customer_id) AS customers_with_orders
FROM payments p
LEFT JOIN orders o ON p.customer_id = o.customer_id
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE p.success = 1;



