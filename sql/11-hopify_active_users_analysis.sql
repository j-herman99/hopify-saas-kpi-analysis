/*
Created By: Jade Herman
Created On: 2025-05-13
Description:  Hopify Active User Count

*/


--Monthly Active Customers (Orders-based)

SELECT
    strftime('%Y-%m', order_date) AS activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
	
FROM 
	orders

GROUP BY 
	activity_month
ORDER BY 
	activity_month DESC;


--Monthly Active Customers (Payments-based)

SELECT
    strftime('%Y-%m', payment_date) AS activity_month,
    COUNT(DISTINCT customer_id) AS active_customers
	
FROM
	payments
	
WHERE
	success = 1
	
GROUP BY 
	activity_month

ORDER BY 
	activity_month DESC;

