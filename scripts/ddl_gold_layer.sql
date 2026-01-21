/*================================================================================================================
      Creating gold layer database and Dim(customer,product) view and fact(sale) view using star model
      
      dwh_gold gold layer database
      Dim_customer having all information related to customers
      Dim_product having all information related to products
      fact_sales having all transactional sales and order details

/*------------------------------------------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Creating dwh_gold database <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------------------------------------------------------------*/


DROP DATABASE IF EXISTS dwh_gold;
CREATE DATABASE dwh_gold;

/*------------------------------------------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Creating dim_customer view <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------------------------------------------------------------*/

DROP VIEW IF EXISTS dwh_gold.dim_customer;
CREATE VIEW dwh_gold.dim_customer AS
SELECT 
ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, 				-- Surrogated key to obtain primary key
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname AS last_name,
la.cntry AS country,
ci.cst_marital_status AS marital_status,
CASE WHEN ci.cst_gndr!= 'unknown' THEN ci.cst_gndr
	ELSE ca.gen
END AS gender,
ca.bdate AS birthdate,
ci.cst_create_date AS create_date
FROM dwh_silver.crm_cust_info ci
LEFT JOIN dwh_silver.erp_cust_az12 ca
ON ca.cid = ci.cst_key
LEFT JOIN dwh_silver.erp_loc_a101 la
ON la.cid=ci.cst_key;

/*------------------------------------------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Creating dim_product view <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------------------------------------------------------------*/

DROP VIEW IF EXISTS dwh_gold.dim_product;
CREATE VIEW dwh_gold.dim_product AS 
SELECT 
ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt) AS product_key,
pi.prd_id AS product_id,
pi.prd_key AS product_number,
pi.prd_nm AS product_name,
pi.cat_id As category_id,
cg.cat AS category,
cg.subcat AS subcategory,
cg.maintenance,
pi.prd_cost AS product_amount,
pi.prd_line AS product_line,
pi.prd_start_dt AS start_date
FROM dwh_silver.crm_prd_info pi
LEFT JOIN  dwh_silver.erp_px_cat_g1v2 cg
ON cg.id = pi.cat_id
WHERE pi.prd_end_dt IS NULL ;     -- filtering historical data.


/*------------------------------------------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>> Creating fact_sales view <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------------------------------------------------------------*/
DROP VIEW IF EXISTS dwh_gold.fact_sales;
CREATE VIEW dwh_gold.fact_sales AS 
SELECT 
sd.sls_ord_num AS order_number,
dp.product_key,
dc.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales,
sd.sls_quantity AS quantity,
sd.sls_price AS price
FROM dwh_silver.crm_sales_details sd
LEFT JOIN dwh_gold.dim_customer dc
ON dc.customer_id = sd.sls_cust_id
LEFT JOIN dwh_gold.dim_product dp
ON dp.product_number = sd.sls_prd_key

/*------------------------------------------------------------------------------------------------------------
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>END <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
--------------------------------------------------------------------------------------------------------------*/


