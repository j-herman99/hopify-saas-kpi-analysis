/* 
==================================================================================================
📄 Filename     : 08_nrr_grr_by_signup_cohort.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly NRR & GRR by Signup Cohort
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Monthly NRR & GRR by Signup Cohort
-- ===============================================================================================

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