/*
===============================================================================
Products Report
===============================================================================
Script Purpose:
	This script creates the view in the database to generate the products report.
	The report consolidates key product metrics and behaviors.

Highlights:
	1. Gathers essential fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in months).
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order value
		- average monthly revenue.
===============================================================================
*/

CREATE VIEW gold.report_products AS

-- ============================================================================
-- 1. Base Query: Retrieves core columns from tables.
-- ============================================================================
WITH base_query AS (
SELECT
s.order_number,
s.customer_key,
s.product_key,
p.product_name,
p.category,
p.subcategory,
p.cost,
p.start_date,
s.sales,
s.quantity,
s.order_date
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL)

-- ============================================================================
-- 2. Aggregations
-- ============================================================================

, aggregated_products AS (
SELECT
product_name,
category,
subcategory,
cost,
start_date,
COUNT(DISTINCT order_number) AS total_orders,
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(DISTINCT customer_key) AS total_customers,
MAX(order_date) AS last_order,
DATEDIFF(month, MAX(order_date), GETDATE()) AS recency
FROM base_query
GROUP BY
product_name,
category,
subcategory,
cost,
start_date)

SELECT
product_name,
category,
subcategory,
cost,
DATEDIFF(month, start_date, GETDATE()) as lifespan,
total_orders,
total_sales,
CASE
	WHEN total_sales > 50000 THEN 'High-Performer'
	WHEN total_sales >= 10000 THEN 'Mid-Range'
	ELSE 'Low-Performer'
END product_segment,
total_quantity,
total_customers,
last_order,
recency,
-- Compute average order value
CASE
	WHEN total_orders = 0 THEN 0
	ELSE total_sales / total_orders
END avg_order_value,
--Compute average monthly revenue
CASE
	WHEN DATEDIFF(month, start_date, GETDATE()) = 0 THEN total_sales
	ELSE total_sales / DATEDIFF(month, start_date, GETDATE())
END avg_monthly_revenue
FROM aggregated_products
