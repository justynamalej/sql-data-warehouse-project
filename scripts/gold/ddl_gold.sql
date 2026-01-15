/*
=========================================================
DDL Script: Create Gold Views
=========================================================
Script Purpose:
  The script creates views for Gold Layer in the data warehouse.
  The Gold Layer represents the final dimension and fact tables.

  Each view performs transformations and combines data from the Silver Layer to produce a clean, enriched, and business-ready dataset.

Usage:
  These views can be queried directly for analytics and reporting.
==========================================================
*/

-- =======================================================
-- Create Dimension: gold.dim_customers
-- =======================================================

CREATE VIEW gold.dim_customers AS
SELECT
ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_maritalstatus AS marital_status,
CASE
WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr		--CRM is a Master for gender info
ELSE COALESCE(ca.gen, 'n/a')
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

-- =======================================================
-- Create Dimension: gold.dim_products
-- =======================================================

CREATE VIEW gold.dim_products AS
SELECT
ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
pn.prd_id AS product_id,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.cat AS category,
pc.subcat AS subcategory,
pc.maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL		--Filter out all the historical data

-- =======================================================
-- Create Fact: gold.fact_sales
-- =======================================================

CREATE VIEW gold.fact_sales AS
SELECT
so.sls_ord_num AS order_number,
pr.product_key,
cu.customer_key,
so.sls_order_dt AS order_date,
so.sls_ship_dt AS shipping_date,
so.sls_due_dt AS due_date,
so.sls_sales AS sales,
so.sls_quantity AS quantity,
so.sls_price AS price
FROM silver.crm_sales_details as so
LEFT JOIN gold.dim_products pr
ON so.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON so.sls_cust_id = cu.customer_id
