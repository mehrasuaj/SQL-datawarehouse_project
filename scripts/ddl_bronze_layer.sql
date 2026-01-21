/* =======================================================================================================================================================================================
 >>>>>>>>>> -- CREATING DATABASE dwh_bronze AND TABLE FOR  BRONZE LAYER <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
 
===========================================================================================================================================================================================*/

DROP DATABASE IF EXISTS dwh_bronze;														-- Dropping database dwh_bronze if exisits.

CREATE DATABASE dwh_bronze;																-- creating database dwh_bronze 

USE dwh_bronze;

/*-----------------------------------------------------------------------------------------------------------------------------------------------------
    >>> CREATING TABLE FOR dwh_bronze database
-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.crm_cust_info;											-- Dropping table crm_cust_info if exisits.
 
CREATE TABLE dwh_bronze.crm_cust_info (													-- creating table crm_cust_info
	cst_id VARCHAR(50),
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_marital_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date VARCHAR(50)
);

/*----------------------------------------------------------------------------------*/
/* NOTE- Creating raw tables with '_raw' to fetch the input CSV data into it and 
then later will use store procedure to insert it's data into our original table like crm_cust_info.
It is because in MYSQL store procedure doesn't allow LOAD DATA inside the procedure.*/
/*----------------------------------------------------------------------------------*/

CREATE TABLE dwh_bronze.crm_cust_info_raw LIKE dwh_bronze.crm_cust_info;					-- creating RAW table crm_cust_info_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.crm_prd_info; 												-- Dropping table crm_prd_info if exisits.

CREATE TABLE dwh_bronze.crm_prd_info (														-- creating table crm_prd_info 
	prd_id VARCHAR(50),
	prd_key VARCHAR(50),
	prd_nm VARCHAR (255),
	prd_cost VARCHAR(50),
	prd_line VARCHAR(50),
	prd_start_dt VARCHAR(50),
	prd_end_dt VARCHAR(50)
);
CREATE TABLE dwh_bronze.crm_prd_info_raw LIKE dwh_bronze.crm_prd_info;							-- creating RAW table crm_prd_info_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.crm_sales_details; 												-- Dropping table crm_sales_details if exisits.
 
CREATE TABLE dwh_bronze.crm_sales_details(														-- creating table crm_sales_details
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id VARCHAR(50),
	sls_order_dt VARCHAR(50),
	sls_ship_dt VARCHAR(50),
	sls_due_dt VARCHAR(50),
	sls_sales VARCHAR(50),
	sls_quantity VARCHAR(50),
	sls_price VARCHAR(50)
);
CREATE TABLE dwh_bronze.crm_sales_details_raw LIKE dwh_bronze.crm_sales_details;					-- creating RAW table crm_sales_details_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.erp_cust_az12;														-- Dropping table erp_cust_az12 if exisits.

CREATE TABLE dwh_bronze.erp_cust_az12 (																-- creating table erp_cust_az12 
	cid VARCHAR(50),
	bdate VARCHAR(50),
	gen VARCHAR(50)
);
CREATE TABLE dwh_bronze.erp_cust_az12_raw LIKE dwh_bronze.erp_cust_az12;							-- creating RAW table erp_cust_az12_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.erp_loc_a101; 															-- Dropping table erp_loc_a101 if exisits.

CREATE TABLE dwh_bronze.erp_loc_a101 (																	-- creating table erp_loc_a101 
	cid VARCHAR(50),
	cntry VARCHAR(50)
);
CREATE TABLE dwh_bronze.erp_loc_a101_raw LIKE dwh_bronze.erp_loc_a101;									-- creating RAW table erp_loc_a101_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.erp_px_cat_g1v2; 														-- Dropping table erp_px_cat_g1v2 if exisits.
 
CREATE TABLE dwh_bronze.erp_px_cat_g1v2 (																-- creating table erp_px_cat_g1v2
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);

CREATE TABLE dwh_bronze.erp_px_cat_g1v2_raw LIKE dwh_bronze.erp_px_cat_g1v2;							-- creating RAW table erp_px_cat_g1v2_raw

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/

-- Creating table to catch error occurs while loading
/*------------------------------------------------------*/

DROP TABLE IF EXISTS dwh_bronze.load_error; 															-- Dropping table load_error if exisits.
 
 CREATE TABLE dwh_bronze.load_error (																	-- creating table load_error
   error_number INT,
   error_sqlstate CHAR(5),
   error_message TEXT,
   error_occured_at TIMESTAMP
 );

/*-----------------------------------------------------------------------------------------------------------------------------------------------------*/





















