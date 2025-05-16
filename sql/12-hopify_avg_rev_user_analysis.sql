
/*

Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Average Revenue Per User (ARPU)


*/


--ARPU Over Time (Global)

WITH monthly_revenue AS (

    SELECT
        strftime('%Y-%m', payment_date) AS month,
        SUM(payment_amount) AS total_revenue
		
    FROM 
		payments
	
    WHERE
		success = 1
		
    GROUP BY 
		month
),
monthly_active_users AS (

    SELECT
        strftime('%Y-%m', payment_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
		
    FROM payments
	
    WHERE 
		success = 1
	
    GROUP BY
		month
)
SELECT
    r.month,
    r.total_revenue,
    u.active_customers,
    ROUND(r.total_revenue / u.active_customers, 2) AS arpu
	
FROM 
	monthly_revenue AS r

JOIN monthly_active_users AS u
	ON r.month = u.month

ORDER BY 
	r.month DESC;


--ARPU by Segment Over Time

WITH monthly_segment_revenue AS (

    SELECT
        strftime('%Y-%m', p.payment_date) AS month,
        c.customer_segment,
        SUM(p.payment_amount) AS total_revenue
		
    FROM payments AS p
	
    JOIN customers AS c 
		ON p.customer_id = c.customer_id
	
    WHERE
		p.success = 1
		
    GROUP BY 
		month, c.customer_segment
),
monthly_segment_active_users AS (

    SELECT
        strftime('%Y-%m', p.payment_date) AS month,
        c.customer_segment,
        COUNT(DISTINCT p.customer_id) AS active_customers
		
    FROM payments AS p
	
    JOIN customers AS c 
		ON p.customer_id = c.customer_id

    WHERE
		p.success = 1
	
    GROUP BY 
		month, c.customer_segment
	
)
SELECT
    r.month,
    r.customer_segment,
    r.total_revenue,
    u.active_customers,
    ROUND(r.total_revenue / u.active_customers, 2) AS arpu
	
FROM 
	monthly_segment_revenue AS r

JOIN monthly_segment_active_users AS u
	ON r.month = u.month AND r.customer_segment = u.customer_segment

ORDER BY 
	r.month DESC, r.customer_segment;
	
	------
	
-- ARPU by Segment and Month with Global Benchmark from benchmarks table
SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(o.total_amount), 2) AS "Total Revenue",
    COUNT(DISTINCT c.customer_id) AS "Active Customers",
    ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS "ARPU",
    -- Pull company-wide ARPU target (example: MRR Target / estimated customers)
    (SELECT target_value FROM benchmarks WHERE metric_name = 'MRR Target') / 50000 AS "Benchmark ARPU",
    -- Optional variance calculation
    ROUND((SUM(o.total_amount) * 1.0 / COUNT(DISTINCT c.customer_id) - (SELECT target_value FROM benchmarks WHERE metric_name = 'MRR Target') / 50000) * 100.0 / ((SELECT target_value FROM benchmarks WHERE metric_name = 'MRR Target') / 50000), 2) AS "Variance %"
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
GROUP BY
    "Month", c.customer_segment
ORDER BY
    "Month" DESC, c.customer_segment;



	--------
	
	
