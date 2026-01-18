/*
===============================================================================
Customer Report
===============================================================================
Script Purpose:
	This report consolidates key customer metrics and behaviors.

Highlights:
	1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in months).
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend.
===============================================================================
*/

CREATE VIEW gold.report_customers AS

-- ============================================================================
-- 1. Base Query: Retrieves core columns from tables.
-- ============================================================================

WITH base_query AS (
SELECT
s.order_number,
s.product_key,
s.order_date,
s.sales,
s.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
c.birthdate,
DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
WHERE s.order_date IS NOT NULL)

-- ============================================================================
-- 2. Aggregations
-- ============================================================================
, customer_aggregation AS (
SELECT
customer_key,
customer_number,
customer_name,
age,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT product_key) AS total_products,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY
customer_key,
customer_number,
customer_name,
age)

SELECT
customer_key,
customer_number,
customer_name,
age,
CASE
	WHEN age < 20 THEN 'Below 20'
	WHEN age BETWEEN 20 AND 30 THEN '20-30'
	WHEN age BETWEEN 30 AND 50 THEN '30-50'
	ELSE 'Above 50'
END age_group,
CASE
	WHEN lifespan > 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan > 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
last_order,
lifespan,
DATEDIFF(month, last_order, GETDATE()) AS recency,
-- Compute average order value
CASE
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END avg_order_value,
-- Compute average monthly spend
CASE
	WHEN lifespan = 0 THEN total_sales
	ELSE total_sales / lifespan
END avg_monthly_spend
FROM customer_aggregation
