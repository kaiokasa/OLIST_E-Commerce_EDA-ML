USE olist_ecommerce;
/*growth and Revenue Analysis*/

/*total revenue generated from delivered products by the platform*/
SELECT SUM(oi.price + oi.freight_value) AS total_revenue
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "delivered";

/*Yearly generated revenue*/
SELECT YEAR(o.order_delivered_customer_date) AS year, ROUND(SUM(oi.price + oi.freight_value),2) AS total_value
FROM orders AS o
INNER JOIN order_items AS oi
ON o.order_id = oi.order_id
WHERE o.order_status = "delivered" AND o.order_delivered_customer_date > 0
GROUP BY year
ORDER BY year;

/*growth percentage month over month for delivered products only*/
WITH year_month_table AS(
	SELECT DATE_FORMAT(o.order_delivered_customer_date, '%Y-%m') AS y_month,
		   ROUND(SUM(price + freight_value),2) AS total_revenue
	FROM orders AS o
	INNER JOIN order_items AS oi
	ON o.order_id = oi.order_id
	WHERE order_status = 'delivered' AND YEAR(o.order_delivered_customer_date) > 0
	GROUP BY y_month	
)
SELECT y_month, 
	   LAG(total_revenue) OVER (ORDER BY y_month) AS last_month_revenue, 
       total_revenue,
       ROUND((total_revenue - LAG(total_revenue) OVER(ORDER BY y_month))/LAG(total_revenue) OVER(ORDER BY y_month)*100,2) AS growth_percentage
FROM year_month_table
ORDER BY y_month;

