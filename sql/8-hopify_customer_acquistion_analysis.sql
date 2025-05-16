/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Customer Acquisition Trend

*/


--New Customers Acquired per Month

SELECT
    strftime('%Y-%m', signup_date) AS "Signup Month",
    COUNT(customer_id) AS "New Customers"
	
FROM 
    customers
	
GROUP BY 
    "Signup Month"
	
ORDER BY 
    "Signup Month" DESC;

