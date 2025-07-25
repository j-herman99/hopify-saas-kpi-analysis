WITH monthly_active_customers AS (
    SELECT 
        DATE(strftime('%Y-%m-01', order_date)) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    GROUP BY 1
),

rolling_3mo_avg AS (
    SELECT 
        mac.month,
        mac.active_customers,
        ROUND(AVG(mac.active_customers) OVER (
            ORDER BY mac.month 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_avg_3mo
    FROM monthly_active_customers mac
)

SELECT * 
FROM rolling_3mo_avg
ORDER BY month DESC;
