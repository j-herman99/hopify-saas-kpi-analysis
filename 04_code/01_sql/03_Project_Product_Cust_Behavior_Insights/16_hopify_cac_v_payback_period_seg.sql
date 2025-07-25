-- ========================================================
-- Hopify SaaS – CAC Payback Period by Segment (in Months)
-- ========================================================

WITH total_cac AS (
    SELECT
        LOWER(segment) AS segment,
        SUM(monthly_budget) AS total_cac
    FROM marketing_spend
    GROUP BY segment
),

arpu_by_segment AS (
    SELECT
        LOWER(segment) AS segment,
        SUM(subscription_amount) AS total_revenue,
        COUNT(DISTINCT customer_id) AS total_customers,
        ROUND(SUM(subscription_amount) * 1.0 / COUNT(DISTINCT customer_id), 2) AS arpu
    FROM subscriptions
    GROUP BY customer_segment
)

SELECT
    t.segment AS customer_segment,
    ROUND(t.total_cac, 2) AS total_cac_usd,
    a.arpu,
    ROUND(t.total_cac / a.arpu, 2) AS cac_payback_months,
    ROUND((t.total_cac / a.arpu) * 30.44, 1) AS cac_payback_days
FROM total_cac t
JOIN arpu_by_segment a
  ON t.segment = a.segment
ORDER BY cac_payback_days DESC;