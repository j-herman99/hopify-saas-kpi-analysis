/*
Created By: Jade Herman
Created On: 2025-05-13
Description:  Hopify Net Revenu Retention (NRR) & Gross Revenue Retention (GRR)

*/

--Monthly NRR & GRR by Cohort

WITH cohort_base AS (

    SELECT 
        c.customer_id,
        strftime('%Y-%m', s.start_date) AS cohort_month,
        s.subscription_price AS start_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        customers AS c
		
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.change_type = 'signup'
),

churned_revenue AS (

    SELECT 
        c.customer_id,
        strftime('%Y-%m', s.start_date) AS cohort_month,
        SUM(s.subscription_price) AS churned_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        churn_events AS ce
		
        ON s.customer_id = ce.customer_id
		
    JOIN 
        customers AS c
		
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.start_date < ce.churn_date
		
    GROUP BY 
        c.customer_id, cohort_month
),

expansion_revenue AS (

    SELECT 
        c.customer_id,
        strftime('%Y-%m', s.start_date) AS cohort_month,
        SUM(s.subscription_price) AS expansion_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        customers AS c
		
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.change_type IN ('upgrade', 'reactivation')
		
    GROUP BY 
        c.customer_id, cohort_month
)
SELECT 
    cb.cohort_month AS "Cohort Month",
    ROUND(SUM(cb.start_mrr), 2) AS "Starting MRR",
    ROUND(SUM(cr.churned_mrr), 2) AS "Churned MRR",
    ROUND(SUM(er.expansion_mrr), 2) AS "Expansion MRR",
	
    ROUND(
        (SUM(cb.start_mrr) - SUM(cr.churned_mrr)) * 1.0 / SUM(cb.start_mrr) * 100,
        2
		
    ) AS "Gross Revenue Retention %",
	
    ROUND(
        (SUM(cb.start_mrr) - SUM(cr.churned_mrr) + SUM(er.expansion_mrr)) * 1.0 / SUM(cb.start_mrr) * 100,
        2
		
    ) AS "Net Revenue Retention %"
	
FROM 
    cohort_base AS cb
	
LEFT JOIN 
    churned_revenue AS cr
    ON cb.customer_id = cr.customer_id
	
LEFT JOIN 
    expansion_revenue AS er
    ON cb.customer_id = er.customer_id
	
GROUP BY 
    cb.cohort_month
	
ORDER BY 
    cb.cohort_month DESC;
	

--Net Revenue Retention (NRR) & Gross Revenue Retention by Customer Segment

WITH base_revenue AS (

    SELECT 
        c.customer_segment,
        s.customer_id,
        SUM(s.subscription_price) AS starting_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        customers AS c
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.change_type = 'signup'
		
    GROUP BY 
        c.customer_segment, s.customer_id
),

churned_revenue AS (

    SELECT 
        c.customer_segment,
        s.customer_id,
        SUM(s.subscription_price) AS churned_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        churn_events AS ce
        ON s.customer_id = ce.customer_id
		
    JOIN 
        customers AS c
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.start_date < ce.churn_date
		
    GROUP BY 
        c.customer_segment, s.customer_id
),
expansion_revenue AS (
    SELECT 
        c.customer_segment,
        s.customer_id,
        SUM(s.subscription_price) AS expansion_mrr
		
    FROM 
        subscriptions AS s
		
    JOIN 
        customers AS c
        ON s.customer_id = c.customer_id
		
    WHERE 
        s.change_type IN ('upgrade', 'reactivation')
		
    GROUP BY 
        c.customer_segment, s.customer_id
)
SELECT 
    br.customer_segment AS "Customer Segment",
    ROUND(SUM(br.starting_mrr), 2) AS "Starting MRR",
    ROUND(SUM(cr.churned_mrr), 2) AS "Churned MRR",
    ROUND(SUM(er.expansion_mrr), 2) AS "Expansion MRR",
    ROUND(
        (SUM(br.starting_mrr) - SUM(cr.churned_mrr)) * 1.0 / SUM(br.starting_mrr) * 100,
        2
		
    ) AS "Gross Revenue Retention %",
	
    ROUND(
        (SUM(br.starting_mrr) - SUM(cr.churned_mrr) + SUM(er.expansion_mrr)) * 1.0 / SUM(br.starting_mrr) * 100,
        2
		
    ) AS "Net Revenue Retention %"
	
FROM 
    base_revenue AS br
	
LEFT JOIN 
    churned_revenue AS cr
    ON br.customer_id = cr.customer_id AND br.customer_segment = cr.customer_segment
	
LEFT JOIN 
    expansion_revenue AS er
    ON br.customer_id = er.customer_id AND br.customer_segment = er.customer_segment
	
GROUP BY 
    br.customer_segment
	
ORDER BY 
    "Gross Revenue Retention %" DESC;

	
--NRR & GRR by Month (Global View)

WITH base_mrr AS (

    SELECT 
        strftime('%Y-%m', start_date) AS month,
        SUM(subscription_price) AS starting_mrr
		
    FROM subscriptions
	
    WHERE change_type = 'signup'
	
    GROUP BY month
),
churn_mrr AS (

    SELECT 
        strftime('%Y-%m', churn_date) AS month,
        SUM(s.subscription_price) AS churned_mrr
		
    FROM churn_events AS ce
	
    JOIN subscriptions AS s
    ON ce.customer_id = s.customer_id
	
    WHERE s.start_date < ce.churn_date
	
    GROUP BY month
),
expansion_mrr AS (

    SELECT 
        strftime('%Y-%m', start_date) AS month,
        SUM(subscription_price) AS expansion_mrr
		
    FROM subscriptions
	
    WHERE change_type IN ('upgrade', 'reactivation')
	
    GROUP BY month
)
SELECT 
    bm.month AS "Month",
    ROUND(bm.starting_mrr, 2) AS "Starting MRR",
    ROUND(COALESCE(cm.churned_mrr, 0), 2) AS "Churned MRR",
    ROUND(COALESCE(em.expansion_mrr, 0), 2) AS "Expansion MRR",
    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0)) * 1.0 / bm.starting_mrr * 100, 2) AS "GRR %",
    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0) + COALESCE(em.expansion_mrr, 0)) * 1.0 / bm.starting_mrr * 100, 2) AS "NRR %"
	
FROM 
    base_mrr AS bm

LEFT JOIN 
    churn_mrr AS cm
    ON bm.month = cm.month
	
LEFT JOIN 
    expansion_mrr AS em
    ON bm.month = em.month
	
ORDER BY 
    bm.month DESC;


--NRR & GRR by Customer Segment & Month

WITH base_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', s.start_date) AS month,
        SUM(s.subscription_price) AS starting_mrr
    FROM subscriptions AS s
    JOIN customers AS c ON s.customer_id = c.customer_id
    WHERE s.change_type = 'signup'
    GROUP BY c.customer_segment, month
),

churn_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', ce.churn_date) AS month,
        SUM(s.subscription_price) AS churned_mrr
    FROM churn_events AS ce
    JOIN subscriptions AS s ON ce.customer_id = s.customer_id
    JOIN customers AS c ON ce.customer_id = c.customer_id
    WHERE s.start_date < ce.churn_date
    GROUP BY c.customer_segment, month
),

expansion_mrr AS (
    SELECT 
        c.customer_segment,
        strftime('%Y-%m', s.start_date) AS month,
        SUM(s.subscription_price) AS expansion_mrr
    FROM subscriptions AS s
    JOIN customers c ON s.customer_id = c.customer_id
    WHERE s.change_type IN ('upgrade', 'reactivation')
    GROUP BY c.customer_segment, month
),

benchmarks_resolved AS (
    SELECT segment, metric_name, target_value
    FROM benchmarks
    WHERE segment != 'All Segments'

    UNION

    SELECT 'SMB', metric_name, target_value FROM benchmarks WHERE segment = 'All Segments'
    UNION
    SELECT 'Mid-Market', metric_name, target_value FROM benchmarks WHERE segment = 'All Segments'
    UNION
    SELECT 'Enterprise', metric_name, target_value FROM benchmarks WHERE segment = 'All Segments'
)

SELECT 
    bm.customer_segment AS "Customer Segment",
    bm.month AS "Month",
    ROUND(bm.starting_mrr, 2) AS "Starting MRR",
    ROUND(COALESCE(cm.churned_mrr, 0), 2) AS "Churned MRR",
    ROUND(COALESCE(em.expansion_mrr, 0), 2) AS "Expansion MRR",

    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0)) * 1.0 / bm.starting_mrr * 100, 2) AS "GRR %",
    ROUND((bm.starting_mrr - COALESCE(cm.churned_mrr, 0) + COALESCE(em.expansion_mrr, 0)) * 1.0 / bm.starting_mrr * 100, 2) AS "NRR %",

    br_nrr.target_value AS "NRR % Target",
    br_grr.target_value AS "GRR % Target"

FROM base_mrr AS bm
LEFT JOIN churn_mrr AS cm
    ON bm.customer_segment = cm.customer_segment AND bm.month = cm.month
LEFT JOIN expansion_mrr AS em
    ON bm.customer_segment = em.customer_segment AND bm.month = em.month

LEFT JOIN benchmarks_resolved AS br_nrr
    ON br_nrr.segment = bm.customer_segment AND br_nrr.metric_name = 'NRR % Target'

LEFT JOIN benchmarks_resolved AS br_grr
    ON br_grr.segment = bm.customer_segment AND br_grr.metric_name = 'GRR % Target'

ORDER BY bm.month DESC, bm.customer_segment;

