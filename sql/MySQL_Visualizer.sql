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

