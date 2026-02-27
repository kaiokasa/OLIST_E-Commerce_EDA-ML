USE olist_ecommerce;
/*growth and Revenue Analysis*/
SELECT SUM(price + freight_value) AS total_revenue
FROM order_items;

/*Yearly generated revenue*/
SELECT YEAR(o.order_purchase_timestamp) AS year, SUM(price + freight_value) AS total_revenue
FROM order_items AS oi
INNER JOIN orders AS o
ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY YEAR(o.order_purchase_timestamp) ORDER BY year ASC;

/*Monthly generated revenue over all the years (year-month-revenue)*/
SELECT DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month, SUM(oi.price + oi.freight_value) AS total_revenue
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE order_status = "delivered"
GROUP BY month
ORDER BY month ASC;

/*growth percentage month over month*/



