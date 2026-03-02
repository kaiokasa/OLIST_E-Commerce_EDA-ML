USE olist_ecommerce;
SHOW TABLES;

SELECT * FROM customers;
SELECT * FROM sellers;
SELECT * FROM geolocation;
SELECT * FROM category_name_translation;
SELECT * FROM products;
SELECT * FROM orders;
SELECT * FROM order_items;
SELECT * FROM order_payments;
SELECT * FROM order_reviews;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM sellers;
SELECT COUNT(*) FROM geolocation;
SELECT COUNT(*) FROM category_name_translation;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_payments;
SELECT COUNT(*) FROM order_reviews;

USE olist_ecommerce;
SELECT 
    SUM(price + freight_value) AS total_revenue
        FROM order_items;	
        
SELECT 
    YEAR(o.order_purchase_timestamp) AS year,
    SUM(oi.price + oi.freight_value) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY year;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price + oi.freight_value) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

SELECT
    month,
    revenue,
    previous_month_revenue,
    ROUND(
        (revenue - previous_month_revenue) 
        / NULLIF(previous_month_revenue, 0) * 100,
        2
    ) AS growth_percentage
FROM (
    SELECT 
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM (
        SELECT 
            DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
            SUM(oi.price + oi.freight_value) AS revenue
        FROM orders o
        JOIN order_items oi 
            ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
    ) AS monthly_revenue
) AS final_table
ORDER BY month;


WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
),
growth_calc AS (
    SELECT 
        month,
        revenue,
        ROUND(
            ((revenue - LAG(revenue) OVER (ORDER BY month)) 
            / LAG(revenue) OVER (ORDER BY month)) * 100, 
        2) AS growth_percentage
    FROM monthly_revenue
)
SELECT *
FROM growth_calc
ORDER BY growth_percentage DESC
LIMIT 1;

WITH customer_orders AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS y_month,
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN customers c 
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m'),
        c.customer_unique_id
)
SELECT
    y_month,
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) 
        / COUNT(*) * 100, 
        2
    ) AS repeat_purchase_rate
FROM customer_orders
GROUP BY y_month
ORDER BY y_month;
