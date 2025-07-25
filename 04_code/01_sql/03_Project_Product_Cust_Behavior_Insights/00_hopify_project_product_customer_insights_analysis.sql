/*

Created By: Jade Herman
Created On: 2025-05-13

📊 Project 3: Product Performance & Customer Insights

🌟 Executive Summary:
This project analyzes revenue-driving product categories, customer segment behavior, acquisition trends, and engagement levels. By surfacing KPIs like top-selling products, AOV, support interactions, and churn trends, this analysis helps inform product strategy, customer success efforts, and retention planning.

📊 Key Focus Areas:
1. Product revenue & AOV insights by category and segment
2. Customer behavior by segment: churn, orders, support
3. Acquisition trends and cumulative growth
4. Active user analysis across orders and payments

*/

------------------------------------------------------------------------------------------------------------
--- 1. Executive Summary: Top Product Category by Revenue and AOV
------------------------------------------------------------------------------------------------------------

WITH category_revenue AS (
    
	SELECT
        p.category AS category,
        SUM(
            CASE
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0
                    THEN oi.quantity * p.price
                ELSE oi.subtotal
            END
        ) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders
    
	FROM order_items AS oi
    
	JOIN products AS p ON oi.product_id = p.product_id
    
	GROUP BY p.category
),
category_aov AS (

    SELECT
        category,
        ROUND(total_revenue * 1.0 / total_orders, 2) AS aov
		
    FROM 
		category_revenue
)
SELECT
    cr.category AS "Top Product Category",
    ROUND(cr.total_revenue, 2) AS "Total Revenue",
    ca.aov AS "Average Order Value (AOV)"

FROM 
	category_revenue AS cr

JOIN category_aov ca 
	ON cr.category = ca.category

ORDER BY cr.total_revenue DESC

LIMIT 1;



------------------------------------------------------------------------------------------
--- 2. Top Product Categories by Total Revenue & Segment
------------------------------------------------------------------------------------------	
	
SELECT
    c.customer_segment,
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.subtotal), 2) AS total_revenue
FROM 
    order_items AS oi
JOIN 
    products AS p ON oi.product_id = p.product_id
JOIN 
    orders AS o ON oi.order_id = o.order_id
JOIN 
    customers AS c ON o.customer_id = c.customer_id
GROUP BY 
    c.customer_segment, p.category
ORDER BY 
    c.customer_segment, total_revenue DESC;


	
----------------------------------------------------------------------------------------------------
--- 3. Top 10 Best-Selling Products by Segment & Total Revenue
----------------------------------------------------------------------------------------------------

WITH product_revenue_by_segment AS (
    SELECT 
        c.customer_segment AS segment,
        p.name AS product_name,
        p.category AS product_category,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(
            CASE 
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0 
                    THEN oi.quantity * p.price
                ELSE oi.subtotal
            END
        ) AS total_revenue
    FROM 
        order_items AS oi
    JOIN 
        products AS p ON oi.product_id = p.product_id
    JOIN 
        orders AS o ON oi.order_id = o.order_id
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment, p.product_id
),

ranked_products AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY segment 
            ORDER BY total_revenue DESC
        ) AS rank_within_segment
    FROM 
        product_revenue_by_segment
)

SELECT 
    segment,
    product_name,
    product_category,
    total_orders,
    units_sold,
    printf('$%,.2f', total_revenue) AS total_revenue
FROM 
    ranked_products
WHERE 
    rank_within_segment <= 10
ORDER BY 
    segment, rank_within_segment;


----------------------------------------------------------------------------------------------------
--- 4. Average Order Value (AOV) by Segment & Product Category
----------------------------------------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Segment",
    p.category AS "Product Category",
    ROUND(
        SUM(
            CASE 
                WHEN oi.subtotal IS NULL OR oi.subtotal = 0 
                    THEN oi.quantity * p.price
                ELSE oi.subtotal
            END
        ) * 1.0 / COUNT(DISTINCT oi.order_id), 2
    ) AS "Average Order Value (AOV)"

FROM 
    order_items AS oi

JOIN 
    products AS p ON oi.product_id = p.product_id

JOIN 
    orders AS o ON oi.order_id = o.order_id

JOIN 
    customers AS c ON o.customer_id = c.customer_id

GROUP BY 
    c.customer_segment, p.category

ORDER BY 
    c.customer_segment, "Average Order Value (AOV)" DESC;


----------------------------------------------------------------------------
--- 5. Top Cross-Sell Product Combos by Segment
----------------------------------------------------------------------------

SELECT 
    customer_segment AS "Customer Segment",
    CASE 
	
        WHEN cat1 < cat2 THEN cat1 || ' + ' || cat2
		
        ELSE cat2 || ' + ' || cat1
		
    END AS "Category Combo",
	
    COUNT(*) AS "Combo Frequency"
	
FROM (

    SELECT 
        o.order_id,
        c.customer_segment,
        MIN(p.category) AS cat1,
        MAX(p.category) AS cat2,
        COUNT(DISTINCT p.category) AS category_count
		
    FROM 
        order_items AS oi
		
    JOIN 
        orders AS o 
			ON oi.order_id = o.order_id
		
    JOIN 
        customers AS c 
			ON o.customer_id = c.customer_id
		
    JOIN 
        products AS p 
			ON oi.product_id = p.product_id
		
    GROUP BY 
        o.order_id, c.customer_segment
		
    HAVING 
        category_count = 2
		
) AS two_cat_orders

GROUP BY 
    customer_segment, "Category Combo"
	
ORDER BY 
    customer_segment,
    "Combo Frequency" DESC;
	
	
----------------------------------------------------------------------------------------------------------------
--- 6. Segment Behavior Summary (Churn, AOV, Subscriptions, Support)
----------------------------------------------------------------------------------------------------------------

WITH churn_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(COUNT(DISTINCT ce.customer_id) * 1.0 / 
            (SELECT COUNT(*) 
             FROM customers c2 
             WHERE c2.customer_segment = c.customer_segment) * 100, 2
        ) AS churn_rate
    FROM 
        churn_events AS ce
    JOIN 
        customers AS c ON ce.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

subscription_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(AVG(s.subscription_price), 2) AS avg_subscription_price
    FROM 
        subscriptions AS s
    JOIN 
        customers AS c ON s.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

order_stats AS (
    SELECT 
        c.customer_segment,
        ROUND(SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
    FROM 
        orders AS o
    JOIN 
        customers AS c ON o.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
),

support_stats AS (
    SELECT 
        c.customer_segment,
        COUNT(st.ticket_id) AS support_ticket_volume,
        ROUND(AVG(JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)), 2) AS avg_resolution_days
    FROM 
        support_tickets AS st
    JOIN 
        customers AS c ON st.customer_id = c.customer_id
    GROUP BY 
        c.customer_segment
)

SELECT 
    c.customer_segment AS "Customer Segment",
    COALESCE(ch.churn_rate, 0) AS "Churn Rate %",
    COALESCE(ss.avg_subscription_price, 0) AS "Avg Subscription Price",
    COALESCE(os.avg_order_value, 0) AS "Avg Order Value (AOV)",
    COALESCE(sps.support_ticket_volume, 0) AS "Total Support Tickets",
    COALESCE(sps.avg_resolution_days, 0) AS "Avg Resolution Days"
FROM 
    customers AS c
LEFT JOIN churn_stats AS ch ON c.customer_segment = ch.customer_segment
LEFT JOIN subscription_stats AS ss ON c.customer_segment = ss.customer_segment
LEFT JOIN order_stats AS os ON c.customer_segment = os.customer_segment
LEFT JOIN support_stats AS sps ON c.customer_segment = sps.customer_segment
GROUP BY 
    c.customer_segment
ORDER BY 
    c.customer_segment;

	
	
-------------------------------------------------------
--- 7. Monthly Churn % by Segment (Completed Months Only)
-------------------------------------------------------

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


---------------------------------------------------------------------------------------------
--- 8. Churn Rate by Customer Segment (Lifetime Snapshot)
---------------------------------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(DISTINCT ce.customer_id) AS "Churned Customers",
	
    (
        SELECT COUNT(*) 
		
        FROM customers AS c2 
		
        WHERE c2.customer_segment = c.customer_segment
		
    ) AS "Total Customers",
	
    ROUND(
        COUNT(DISTINCT ce.customer_id) * 1.0 / 
		
        (
            SELECT COUNT(*) 
			
            FROM customers AS c2 
			
            WHERE c2.customer_segment = c.customer_segment
			
        ) * 100, 2
		
    ) AS "Churn Rate %"
	
FROM 
    churn_events AS ce
	
JOIN 
    customers AS c
    ON ce.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Churn Rate %" DESC;

--------------------------------------------------------------------------------------	
--- 9. Avg Subscription Revenue per Customer Segment
--------------------------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Customer Segment",
    ROUND(AVG(s.subscription_price), 2) AS "Avg Subscription Price",
    COUNT(DISTINCT s.customer_id) AS "Customers with Subscriptions"
	
FROM 
    subscriptions AS s
	
JOIN 
    customers AS c
	
    ON s.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Avg Subscription Price" DESC;
	
--------------------------------------------------------------------
--- 10. Order Behavior by Customer Segment
--------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(DISTINCT o.order_id) AS "Total Orders",
    COUNT(DISTINCT c.customer_id) AS "Total Customers",
    ROUND(COUNT(DISTINCT o.order_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS "Orders per Customer",
	
    ROUND(
	
        SUM(o.total_amount) * 1.0 / COUNT(DISTINCT o.order_id), 
        2
		
    ) AS "Avg Order Value (AOV)"
	
FROM 
    customers AS c
	
JOIN 
    orders AS o
    ON c.customer_id = o.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Orders per Customer" DESC;
	
---------------------------------------------------------------------------------------------------------------------
--- 11. Support Ticket Volume & Avg Resolution Time by Customer Segment
---------------------------------------------------------------------------------------------------------------------

SELECT 
    c.customer_segment AS "Customer Segment",
    COUNT(st.ticket_id) AS "Total Support Tickets",
	
    ROUND(AVG(
	
        JULIANDAY(st.resolved_at) - JULIANDAY(st.created_at)
		
    ), 2) AS "Avg Resolution Days"
	
FROM 
    support_tickets AS st
	
JOIN 
    customers AS c
    ON st.customer_id = c.customer_id
	
GROUP BY 
    c.customer_segment
	
ORDER BY 
    "Total Support Tickets" DESC;
	

------------------------------------------------------------------------------------
--- 12. Most Recent Active Users: Orders vs. Payments
------------------------------------------------------------------------------------

WITH orders_activity AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT customer_id) AS orders_active
    FROM orders
    GROUP BY month
),
payments_activity AS (
    SELECT
        strftime('%Y-%m', payment_date) AS month,
        COUNT(DISTINCT customer_id) AS payments_active
    FROM payments
    WHERE success = 1
    GROUP BY month
),
combined_activity AS (
    SELECT 
        o.month,
        o.orders_active,
        COALESCE(p.payments_active, 0) AS payments_active
    FROM orders_activity o
    LEFT JOIN payments_activity p ON o.month = p.month
),
ranked_activity AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY month DESC) AS rn
    FROM combined_activity
)
SELECT 
    curr.month AS "Month",
    curr.orders_active AS "Orders-Based Active",
    curr.payments_active AS "Payments-Based Active",
    prev.orders_active AS "Prev Month Orders",
    prev.payments_active AS "Prev Month Payments",
    ROUND((curr.orders_active - prev.orders_active) * 100.0 / prev.orders_active, 2) AS "Orders Change %",
    ROUND((curr.payments_active - prev.payments_active) * 100.0 / prev.payments_active, 2) AS "Payments Change %"
	
FROM 
	ranked_activity AS curr
	
LEFT JOIN ranked_activity AS prev 
	ON curr.rn = prev.rn - 1
	
WHERE 
	curr.rn = 1;

-----------------------------------------------------------------------------------------------
--- 13. Monthly Active Customers by Segment (Orders-based, Completed Months Only)
-----------------------------------------------------------------------------------------------

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
)

SELECT
    strftime('%Y-%m', o.order_date) AS month,
    c.customer_segment,
    COUNT(DISTINCT o.customer_id) AS active_customers
	
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
JOIN last_full_month lf 
    ON strftime('%Y-%m', o.order_date) <= lf.max_month

GROUP BY
    month, c.customer_segment

ORDER BY 
    month DESC, c.customer_segment;


---------------------------------------------------------------------------------------------------
--- 14. Monthly Unique Active Customers (Orders OR Payments, Completed Months Only)
---------------------------------------------------------------------------------------------------

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
),

combined_activity AS (
    SELECT customer_id, strftime('%Y-%m', order_date) AS month 
    FROM orders

    UNION

    SELECT customer_id, strftime('%Y-%m', payment_date) AS month 
    FROM payments
    WHERE success = 1
)

SELECT
    ca.month,
    COUNT(DISTINCT ca.customer_id) AS unique_active_customers

FROM combined_activity ca
JOIN last_full_month lf ON ca.month <= lf.max_month

GROUP BY ca.month
ORDER BY ca.month DESC;

--------------------------------------------------------------------------------------------------
--- 15. 3-Month Rolling Average: Active Customers from Orders (Completed Months Only)
--------------------------------------------------------------------------------------------------

WITH last_full_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 month')) AS max_month
),

monthly_orders AS (
    SELECT
        strftime('%Y-%m', order_date) AS month,
        COUNT(DISTINCT customer_id) AS active_customers
    FROM orders
    GROUP BY month
),

filtered_months AS (
    SELECT *
    FROM monthly_orders
    WHERE month <= (SELECT max_month FROM last_full_month)
),

rolling_avg AS (
    SELECT 
        month,
        active_customers,
        ROUND(
            AVG(active_customers) OVER (
                ORDER BY month 
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
        ) AS rolling_avg_3mo
    FROM filtered_months
)

SELECT * 
FROM rolling_avg
ORDER BY month DESC;

------------------------------------------------------------------------
---End of File
------------------------------------------------------------------------

