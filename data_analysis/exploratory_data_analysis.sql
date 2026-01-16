/*
==================================================
Exploratory Data Analysis
==================================================
Script Purpose:
	The script contains multiple queries exploring the database on various detail levels - from the lowest to the highest.
	Exploratory Data Analysis was performed to understand the data and decide on the path for further analysis.

Usage:
	For the better visibility and performance, each query should be run separately.
*/

-- ===============================================
-- Database Exploration
-- ===============================================

-- Explore All Objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES;

-- Explore All Columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- ===============================================
-- Dimensions Exploration
-- ===============================================

-- Explore all countries, the customers come from
SELECT DISTINCT country FROM gold.dim_customers

--Explore all product categories
SELECT DISTINCT category, subcategory FROM gold.dim_products

-- Explore all products together with their categories
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products
ORDER BY 1, 2, 3

-- ===============================================
-- Date Exploration
-- ===============================================

-- Explore Order Dates
SELECT
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years
FROM gold.fact_sales

-- Explore Customers Age
SELECT
MIN(birthdate) AS oldest_customer,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers

-- ===============================================
-- Measures Exploration
-- ===============================================

-- Explore Sales Table Measures
SELECT
SUM(sales) AS total_sales,
SUM(quantity) AS total_quantity,
AVG(price) AS avg_price,
COUNT(*) AS total_records,
COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales

-- Explore Products Table Measures
SELECT
COUNT(*) AS total_products,
COUNT(DISTINCT product_key) AS total_products2
FROM gold.dim_products

-- Explore Customers Table Measures
SELECT
COUNT(*) AS total_customers
FROM gold.dim_customers

-- Count number of Customers that has placed an Order
SELECT
COUNT(DISTINCT customer_key) AS active_customers
FROM gold.fact_sales

--Generate a Report that shows all key metrics together
SELECT 'Total Sales' AS metric_name, SUM(sales) AS matric_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS metric_name, SUM(quantity) AS matric_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price' AS metric_name, AVG(price) AS matric_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Records' AS metric_name, COUNT(*) AS matric_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders' AS metric_name, COUNT(DISTINCT order_number) AS matric_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Products' AS metric_name, COUNT(DISTINCT product_key) AS matric_value FROM gold.dim_products
UNION ALL
SELECT 'Total Customers' AS metric_name, COUNT(*) AS matric_value FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers with Order' AS metric_name, COUNT(DISTINCT customer_key) AS matric_value FROM gold.fact_sales


-- ===============================================
-- Magnitude Analysis
-- ===============================================

-- Total Customers by Countries
SELECT
country,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Total Customers by Gender
SELECT
gender,
COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- Total Products by Category
SELECT
category,
COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC

-- Average Cost in Each Category
SELECT
category,
AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC

-- Total revenue generated for each Category
SELECT
p.category,
SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- Total revenue by the Customer
SELECT
c.customer_key,
c.first_name,
c.last_name,
SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY
c.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Distribution of sold items across countries
SELECT
c.country,
SUM(s.sales) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY
c.country
ORDER BY total_revenue DESC


-- ===============================================
-- Ranking: Top N | Bottom N Analysis
-- ===============================================

-- Top 5 products generating the highest revenue
SELECT TOP 5
product_name,
SUM(sales) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY product_name
ORDER BY total_revenue DESC

-- Bottom 5 products in terms of sales
SELECT TOP 5
product_name,
SUM(sales) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY product_name
ORDER BY total_revenue

-- Top 5 subcategories generating the highest revenue
SELECT TOP 5
subcategory,
SUM(sales) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p
ON s.product_key = p.product_key
GROUP BY subcategory
ORDER BY total_revenue DESC

-- Find the top 10 Customers who have generated the highest revenue
SELECT TOP 10
s.customer_key,
c.first_name,
c.last_name,
SUM(sales) total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY 
s.customer_key,
c.first_name,
c.last_name
ORDER BY total_revenue DESC

-- Top 3 Customers with the fewest orders placed
SELECT TOP 3
s.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT s.order_number) orders_count
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY 
s.customer_key,
c.first_name,
c.last_name
ORDER BY orders_count
