CREATE SCHEMA gold

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;


CREATE OR ALTER VIEW  gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,   -- Surrogate key
	cr.cst_id AS customer_id,
	cr.cst_key AS customer_number,
	cr.cst_firstname AS first_name,
	cr.cst_lastname AS last_name,
	lo.cntry AS country,
	CASE 
		WHEN cr.cst_gndr != 'n/a' THEN cr.cst_gndr
		ELSE COALESCE(az.gen, 'n/a')
	END AS gender,
	cr.cst_marital_status AS marital_status,
	az.bdate,
	cr.cst_create_date
	FROM silver.crm_cust_info cr
	LEFT JOIN  silver.erp_loc_a101 lo
	ON cr.cst_key = lo.cid 
	LEFT JOIN silver.erp_cust_az12 az ON
	cr.cst_key = az.cid


IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_date, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_num       AS product_name,
    pn.prd_cat       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_date AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.prd_cat = pc.id
WHERE pn.prd_end_date IS NULL; -- Filter out all historical data

CREATE OR ALTER VIEW gold.fact_sales AS

CREATE SCHEMA gold

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;


CREATE OR ALTER VIEW  gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key,   -- Surrogate key
	cr.cst_id AS customer_id,
	cr.cst_key AS customer_number,
	cr.cst_firstname AS first_name,
	cr.cst_lastname AS last_name,
	lo.cntry AS country,
	CASE 
		WHEN cr.cst_gndr != 'n/a' THEN cr.cst_gndr
		ELSE COALESCE(az.gen, 'n/a')
	END AS gender,
	cr.cst_marital_status AS marital_status,
	az.bdate,
	cr.cst_create_date
	FROM silver.crm_cust_info cr
	LEFT JOIN  silver.erp_loc_a101 lo
	ON cr.cst_key = lo.cid 
	LEFT JOIN silver.erp_cust_az12 az ON
	cr.cst_key = az.cid


IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE OR ALTER VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_date, pn.prd_key) AS product_key, -- Surrogate key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_num       AS product_name,
    pn.prd_cat       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_date AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.prd_cat = pc.id
WHERE pn.prd_end_date IS NULL; -- Filter out all historical data

CREATE OR ALTER VIEW gold.fact_sales AS

select
	sd.sls_ord_num,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt,
	sd.sls_ship_dt,
	sd.sls_due_dt,
	sd.sls_sales,
	sd.sls_quantity,
	sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN  gold.dim_customer dc
on dc.customer_id = sd.sls_cust_id
LEFT JOIN gold.dim_products dp
on dp.product_number = sd.sls_prd_key
 



