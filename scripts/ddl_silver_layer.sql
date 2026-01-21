/* =======================================================================================================================================================================================
 >>>>>>>>>> -- CREATING DATABASE dwh_silver AND TABLE FOR  SILVER LAYER <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
===========================================================================================================================================================================================*/

-- CREATING DATABASE dwh_silver 
/*---------------------------------------------------------------------------------*/
DROP DATABASE IF EXISTS dwh_silver;													-- Dropping Database dwh_silver if exisits.
CREATE DATABASE dwh_silver;															-- Creating Database dwh_silver

USE dwh_silver;
/*---------------------------------------------------------------------------------
-- CREATING TABLE FOR dwh_silver database
----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.crm_cust_info; 										-- Dropping table crm_cust_info if exisits.
 
CREATE TABLE dwh_silver.crm_cust_info (												-- creating table crm_cust_info
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE,
    dwh_create_date TIMESTAMP DEFAULT NOW() 
);

/*----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.crm_prd_info; 											-- Dropping table crm_prd_info if exisits.

CREATE TABLE dwh_silver.crm_prd_info (													-- creating table crm_prd_info
	prd_id INT,
    cat_id VARCHAR(50),
	prd_key VARCHAR(50),
	prd_nm VARCHAR (255),
	prd_cost INT,
	prd_line VARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date TIMESTAMP DEFAULT NOW() 
);


/*----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.crm_sales_details; 											-- Dropping table crm_sales_details if exisits.

CREATE TABLE dwh_silver.crm_sales_details(													-- creating table crm_sales_details 
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
    dwh_create_date TIMESTAMP DEFAULT NOW()
);

/*----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.erp_cust_az12;													-- Dropping table erp_cust_az12 if exisits.

CREATE TABLE dwh_silver.erp_cust_az12 (															-- creating table erp_cust_az12 
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT NOW()
);

/*----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.erp_loc_a101; 													-- Dropping table erp_loc_a101 if exisits.

CREATE TABLE dwh_silver.erp_loc_a101 (															-- creating table erp_loc_a101 
	cid VARCHAR(50),
	cntry VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT NOW()
);


/*----------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_silver.erp_px_cat_g1v2;													-- Dropping table erp_px_cat_g1v2 if exisits.
 
CREATE TABLE dwh_silver.erp_px_cat_g1v2 (															-- creating table erp_px_cat_g1v2 
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50),
    dwh_create_date TIMESTAMP DEFAULT NOW()
);

/*----------------------------------------------------------------------------------*/

-- ERROR TABLE

DROP TABLE IF EXISTS dwh_silver.load_error;

CREATE TABLE dwh_silver.load_error LIKE dwh_bronze.load_error;

/*----------------------------------------------------------------------------------*/




















