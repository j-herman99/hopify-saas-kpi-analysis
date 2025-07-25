/* 
==================================================================================================
📄 Filename     : 03_revenue_by_product_category.sql
📅 Created On   : 2025-05-13
📝 Description  : Monthly Revenue by Product Category (Pivoted by Segment)
📊 Project      : Project 2 – Revenue, Retention & Profitability Analysis
==================================================================================================
*/

-- ===============================================================================================
-- Monthly Revenue by Product Category (Pivoted by Segment)
-- ===============================================================================================


WITH last_complete_month AS (
    SELECT strftime('%Y-%m', date('now', 'start of month', '-1 day')) AS last_month_end
)
SELECT
    strftime('%Y-%m', o.order_date) AS "Month",
    c.customer_segment AS "Segment",
    ROUND(SUM(CASE WHEN p.category = 'POS Hardware & Software' THEN oi.subtotal ELSE 0 END), 2) AS "POS",
    ROUND(SUM(CASE WHEN p.category = 'Payments & Finance' THEN oi.subtotal ELSE 0 END), 2) AS "Payments",
    ROUND(SUM(CASE WHEN p.category = 'Financial Services' THEN oi.subtotal ELSE 0 END), 2) AS "Finance",
    ROUND(SUM(CASE WHEN p.category = 'Apps & Integrations' THEN oi.subtotal ELSE 0 END), 2) AS "Apps",
    ROUND(SUM(CASE WHEN p.category = 'Storefront Tools' THEN oi.subtotal ELSE 0 END), 2) AS "Storefront",
    ROUND(SUM(CASE WHEN p.category = 'Marketing & Growth' THEN oi.subtotal ELSE 0 END), 2) AS "Marketing",
    ROUND(SUM(CASE WHEN p.category = 'Logistics & Shipping' THEN oi.subtotal ELSE 0 END), 2) AS "Logistics"
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
WHERE o.order_date < (SELECT date(last_month_end || '-01', '+1 month') FROM last_complete_month)
GROUP BY "Month", c.customer_segment
ORDER BY "Month" DESC, c.customer_segment;