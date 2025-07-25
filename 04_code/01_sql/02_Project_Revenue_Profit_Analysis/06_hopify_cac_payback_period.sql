/* 
==================================================================================================
📄 Filename     : 06_cac_payback_period.sql
📅 Created On   : 2025-05-13
📝 Description  : CAC & CAC Payback Period by Segment
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- CAC & CAC Payback Period by Segment
-- ===============================================================================================

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