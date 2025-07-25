/* 
==================================================================================================
📄 Filename     : 07_monthly_churn_rate.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Churn % by Segment (Completed Months Only)
📊 Project      : Project 3 – Product Performance & Customer Insights
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Churn % by Segment (Completed Months Only)
-- ===============================================================================================


-- Determine last completed full month
WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
),

-- List of churn months to track activity (through last full month)
churn_months AS (
    SELECT DISTINCT 
        date(strftime('%Y-%m', churn_date) || '-01') AS month_start
    FROM churn_events
    JOIN last_full_month lf
    WHERE strftime('%Y-%m', churn_date) <= lf.max_month
),

-- Churned customers by segment and month
monthly_churn AS (
    SELECT 
        strftime('%Y-%m', ce.churn_date) AS churn_month,
        c.customer_segment,
        COUNT(DISTINCT ce.customer_id) AS churned_customers
    FROM churn_events ce
    JOIN customers c ON ce.customer_id = c.customer_id
    JOIN last_full_month lf ON strftime('%Y-%m', ce.churn_date) <= lf.max_month
    GROUP BY churn_month, c.customer_segment
),

-- Active customers per segment at the start of each churn month
monthly_active AS (
    SELECT 
        strftime('%Y-%m', cm.month_start) AS active_month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM churn_months cm
    JOIN customers c ON c.signup_date < cm.month_start
    LEFT JOIN churn_events ce 
        ON c.customer_id = ce.customer_id 
        AND ce.churn_date < cm.month_start
    WHERE ce.churn_id IS NULL
    GROUP BY active_month, c.customer_segment
)

-- Final churn rate calculation
SELECT 
    ma.active_month AS "Month",
    ma.customer_segment AS "Segment",
    COALESCE(mc.churned_customers, 0) AS "Churned Customers",
    ma.active_customers AS "Active Customers",
    ROUND(
        COALESCE(mc.churned_customers, 0) * 100.0 / NULLIF(ma.active_customers, 0), 
        2
    ) AS "Churn Rate %"
FROM 
    monthly_active ma
LEFT JOIN 
    monthly_churn mc
    ON ma.active_month = mc.churn_month
    AND ma.customer_segment = mc.customer_segment
ORDER BY 
    ma.active_month DESC, ma.customer_segment;