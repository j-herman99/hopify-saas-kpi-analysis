/*
Created By: Jade Herman
Created On: 2025-05-13
Description: Hopify Revenue Trend Breakdown

*/

--Monthly Revenue from Payments (Total Collected Revenue)

SELECT
	strftime('%Y-%m', payment_date) AS "Revenue Month",
	SUM(payment_amount) AS "Total Revenue Collected",
	COUNT(DISTINCT payment_id) AS "Total Payments"

FROM
	payments
	
WHERE
	success = 1
	
GROUP BY
	"Revenue Month"
	
ORDER BY
	"Revenue Month" DESC;
	
/*
✅ Interpretations:
Revenue is scaling consistently as customer base and order volume grow.

AOV remains stable (~$1,000), which aligns well given the segment and product skew adjustments in the v11/v12 dataset.

Healthy monthly growth momentum can be observed, with minor seasonality dips (e.g. July/August slowdowns, which is typical for commerce businesses).

*/	
	
	
--Monthly Revenue Trend - Orders vs Payments

WITH orders_monthly AS (
    SELECT 
        strftime('%Y-%m', order_date) AS "Month",
        SUM(total_amount) AS "Total Order Amount"
    FROM 
        orders
    GROUP BY 
        "Month"
),
payments_monthly AS (
    SELECT 
        strftime('%Y-%m', payment_date) AS "Month",
        SUM(payment_amount) AS "Total Payment Amount"
		
    FROM 
        payments
		
    WHERE 
        success = 1
		
    GROUP BY 
        "Month"
		
)
SELECT 
    o."Month",
    o."Total Order Amount",
    p."Total Payment Amount"
	
FROM 
    orders_monthly o
	
LEFT JOIN 
    payments_monthly p
    ON o."Month" = p."Month"
	
ORDER BY 
    o."Month" DESC;
	
--Monthly Revenue by Product Category (Trend View)

SELECT 
    strftime('%Y-%m', o.order_date) AS "Revenue Month",
    p.category AS "Product Category",
	
    SUM(
        CASE 
		
            WHEN
				oi.subtotal IS NULL OR oi.subtotal = 0 
			
                THEN 
					oi.quantity * p.price
            
			ELSE 
				oi.subtotal
				
        END
    ) AS "Total Revenue"

FROM 
    order_items oi
JOIN 
    orders o
    ON oi.order_id = o.order_id
JOIN 
    products p
    ON oi.product_id = p.product_id
GROUP BY 
    "Revenue Month", "Product Category"
ORDER BY 
    "Revenue Month" DESC, "Total Revenue" DESC;


--Monthly Payments Breakdown by Payment Method

SELECT 

    strftime('%Y-%m', payment_date) AS "Payment Month",
    payment_method AS "Payment Method",
    SUM(payment_amount) AS "Total Collected",
    COUNT(payment_id) AS "Payment Count"
	
FROM 
    payments
	
WHERE 
    success = 1
	
GROUP BY 
    "Payment Month", "Payment Method"
	
ORDER BY 
    "Payment Month" DESC, "Total Collected" DESC;
	
	
---

SELECT
    strftime('%Y-%m', o.order_date) AS "Order Month",
    c.customer_segment AS "Customer Segment",
    p.category AS "Product Category",
    ROUND(SUM(oi.subtotal), 2) AS "Total Revenue",
    COUNT(DISTINCT o.order_id) AS "Total Orders"
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
GROUP BY
    "Order Month", "Customer Segment", "Product Category"
ORDER BY
    "Order Month" DESC,
    "Customer Segment",
    "Product Category";

	
	
----Monthly Revenue by Segment and Category


SELECT
    strftime('%Y-%m', o.order_date) AS "Order Month",
    c.customer_segment AS "Customer Segment",
    p.category AS "Product Category",
    ROUND(SUM(oi.subtotal), 2) AS "Total Revenue",
    COUNT(DISTINCT o.order_id) AS "Total Orders"
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
GROUP BY
    "Order Month", "Customer Segment", "Product Category"
ORDER BY
    "Order Month" DESC,
    "Customer Segment",
    "Product Category";

	
--- Pivoted Monthly Revenue by Segment and Product Category

SELECT
    strftime('%Y-%m', o.order_date) AS "Order Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(CASE WHEN p.category = 'POS Hardware & Software' THEN oi.subtotal ELSE 0 END), 2) AS "POS Hardware & Software Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Payments & Finance' THEN oi.subtotal ELSE 0 END), 2) AS "Payments & Finance Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Financial Services' THEN oi.subtotal ELSE 0 END), 2) AS "Financial Services Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Apps & Integrations' THEN oi.subtotal ELSE 0 END), 2) AS "Apps & Integrations Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Storefront Tools' THEN oi.subtotal ELSE 0 END), 2) AS "Storefront Tools Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Marketing & Growth' THEN oi.subtotal ELSE 0 END), 2) AS "Marketing & Growth Revenue",
    ROUND(SUM(CASE WHEN p.category = 'Logistics & Shipping' THEN oi.subtotal ELSE 0 END), 2) AS "Logistics & Shipping Revenue"
FROM
    orders o
JOIN
    customers c ON o.customer_id = c.customer_id
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
GROUP BY
    "Order Month", "Customer Segment"
ORDER BY
    "Order Month" DESC,
    "Customer Segment";


---ARPU by Segment and Month

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS order_month,
        c.customer_segment,
        SUM(oi.subtotal) AS total_revenue
    FROM
        orders o
    JOIN
        customers c ON o.customer_id = c.customer_id
    JOIN
        order_items oi ON o.order_id = oi.order_id
    GROUP BY
        order_month, c.customer_segment
),
monthly_active_customers AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS order_month,
        c.customer_segment,
        COUNT(DISTINCT c.customer_id) AS active_customers
    FROM
        orders o
    JOIN
        customers c ON o.customer_id = c.customer_id
    GROUP BY
        order_month, c.customer_segment
)
SELECT
    mr.order_month AS "Order Month",
    mr.customer_segment AS "Customer Segment",
    ROUND(mr.total_revenue, 2) AS "Total Revenue",
    mac.active_customers AS "Active Customers",
    ROUND(mr.total_revenue * 1.0 / mac.active_customers, 2) AS "ARPU"
FROM
    monthly_revenue mr
JOIN
    monthly_active_customers mac
    ON mr.order_month = mac.order_month AND mr.customer_segment = mac.customer_segment
ORDER BY
    mr.order_month DESC,
    mr.customer_segment;

-------

-- Pivoted ARPU by Segment and Month

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS month,
        c.customer_segment,
        SUM(o.total_amount) AS revenue,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM
        orders o
    JOIN
        customers c ON o.customer_id = c.customer_id
    GROUP BY
        month, c.customer_segment
)

SELECT
    month AS "Month",
    ROUND(SUM(CASE WHEN customer_segment = 'Enterprise' THEN revenue ELSE 0 END), 2) AS "Enterprise Revenue",
    ROUND(SUM(CASE WHEN customer_segment = 'Enterprise' THEN active_customers ELSE 0 END), 2) AS "Enterprise Active Customers",
    ROUND(SUM(CASE WHEN customer_segment = 'Enterprise' THEN revenue ELSE 0 END) * 1.0 / NULLIF(SUM(CASE WHEN customer_segment = 'Enterprise' THEN active_customers ELSE 0 END), 0), 2) AS "Enterprise ARPU",
    
    ROUND(SUM(CASE WHEN customer_segment = 'Mid-Market' THEN revenue ELSE 0 END), 2) AS "Mid-Market Revenue",
    ROUND(SUM(CASE WHEN customer_segment = 'Mid-Market' THEN active_customers ELSE 0 END), 2) AS "Mid-Market Active Customers",
    ROUND(SUM(CASE WHEN customer_segment = 'Mid-Market' THEN revenue ELSE 0 END) * 1.0 / NULLIF(SUM(CASE WHEN customer_segment = 'Mid-Market' THEN active_customers ELSE 0 END), 0), 2) AS "Mid-Market ARPU",
    
    ROUND(SUM(CASE WHEN customer_segment = 'SMB' THEN revenue ELSE 0 END), 2) AS "SMB Revenue",
    ROUND(SUM(CASE WHEN customer_segment = 'SMB' THEN active_customers ELSE 0 END), 2) AS "SMB Active Customers",
    ROUND(SUM(CASE WHEN customer_segment = 'SMB' THEN revenue ELSE 0 END) * 1.0 / NULLIF(SUM(CASE WHEN customer_segment = 'SMB' THEN active_customers ELSE 0 END), 0), 2) AS "SMB ARPU"
FROM
    monthly_revenue
GROUP BY
    month
ORDER BY
    month DESC;

	
------

-- Simplified ARPU by Segment and Month

SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Customer Segment",
    ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.customer_id), 2) AS "ARPU"
FROM
    orders o
JOIN
    customers c
    ON o.customer_id = c.customer_id
GROUP BY
    "Month", "Customer Segment"
ORDER BY
    "Month" DESC,
    "Customer Segment";

	
	
-----

-- Pivoted Simplified ARPU by Segment and Month

SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    ROUND(SUM(CASE WHEN c.customer_segment = 'Enterprise' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'Enterprise' THEN o.customer_id END), 0), 2) AS "Enterprise ARPU",
    ROUND(SUM(CASE WHEN c.customer_segment = 'Mid-Market' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'Mid-Market' THEN o.customer_id END), 0), 2) AS "Mid-Market ARPU",
    ROUND(SUM(CASE WHEN c.customer_segment = 'SMB' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'SMB' THEN o.customer_id END), 0), 2) AS "SMB ARPU"
FROM
    orders o
JOIN
    customers c
    ON o.customer_id = c.customer_id
GROUP BY
    "Month"
ORDER BY
    "Month" DESC;


----

---ARPU Trend by Segment (Last 12 Months)

SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    ROUND(SUM(CASE WHEN c.customer_segment = 'Enterprise' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'Enterprise' THEN o.customer_id END), 0), 2) AS "Enterprise ARPU",
    ROUND(SUM(CASE WHEN c.customer_segment = 'Mid-Market' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'Mid-Market' THEN o.customer_id END), 0), 2) AS "Mid-Market ARPU",
    ROUND(SUM(CASE WHEN c.customer_segment = 'SMB' THEN o.total_amount ELSE 0 END) * 1.0 / NULLIF(COUNT(DISTINCT CASE WHEN c.customer_segment = 'SMB' THEN o.customer_id END), 0), 2) AS "SMB ARPU"
FROM
    orders o
JOIN
    customers c
    ON o.customer_id = c.customer_id
WHERE
    o.order_date >= date('now', '-12 months')
GROUP BY
    "Month"
ORDER BY
    "Month" DESC;

--

-- ARPU YoY Comparison by Segment

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_date) AS order_month,
        c.customer_segment,
        SUM(o.total_amount) AS total_revenue,
        COUNT(DISTINCT o.customer_id) AS active_customers
    FROM
        orders o
    JOIN
        customers c ON o.customer_id = c.customer_id
    GROUP BY
        order_month, c.customer_segment
),

arpu_calculation AS (
    SELECT
        mr.order_month,
        mr.customer_segment,
        mr.total_revenue,
        mr.active_customers,
        ROUND(mr.total_revenue * 1.0 / mr.active_customers, 2) AS arpu
    FROM
        monthly_revenue mr
),

arpu_yoy AS (
    SELECT
        curr.order_month AS current_month,
        curr.customer_segment,
        curr.arpu AS current_arpu,
        prev.arpu AS prior_year_arpu,
        ROUND((curr.arpu - prev.arpu) * 100.0 / prev.arpu, 2) AS yoy_growth_percent
    FROM
        arpu_calculation curr
    JOIN
        arpu_calculation prev
        ON curr.customer_segment = prev.customer_segment
        AND curr.order_month = strftime('%Y-%m', date(prev.order_month, '+1 year'))
)

SELECT
    current_month,
    customer_segment,
    current_arpu,
    prior_year_arpu,
    yoy_growth_percent
FROM
    arpu_yoy
ORDER BY
    current_month DESC, customer_segment;



SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order,
    COUNT(DISTINCT strftime('%Y-%m', order_date)) AS total_months
FROM orders;

SELECT 
    strftime('%Y-%m', order_date) AS order_month,
    COUNT(*) AS orders
FROM orders
GROUP BY order_month
ORDER BY order_month;


WITH monthly_arpu AS (
    SELECT
        strftime('%Y-%m', order_date) AS order_month,
        ROUND(SUM(total_amount) * 1.0 / COUNT(DISTINCT customer_id), 2) AS arpu
    FROM
        orders
    GROUP BY
        order_month
),
latest_month AS (
    SELECT MAX(order_month) AS month FROM monthly_arpu
),
prior_month AS (
    SELECT strftime('%Y-%m', DATE(MAX(order_date), '-12 months')) AS month FROM orders
)
SELECT
    lm.month AS "Current Month",
    COALESCE(c.arpu, 0) AS "Current ARPU",
    pm.month AS "Prior Year Month",
    COALESCE(p.arpu, 0) AS "Prior ARPU",
    CASE 
        WHEN COALESCE(p.arpu, 0) = 0 THEN NULL
        ELSE ROUND(((COALESCE(c.arpu, 0) - p.arpu) / p.arpu) * 100, 2)
    END AS "YoY ARPU Change %"
FROM
    latest_month lm
LEFT JOIN monthly_arpu c ON c.order_month = lm.month
LEFT JOIN prior_month pm ON 1 = 1
LEFT JOIN monthly_arpu p ON p.order_month = pm.month;


