/* -------------------------------------------------------------------------------------------------------------------------------

CREATING STORE PROCEDURE TO LOAD SILVER LAYER FROM BRONZE LAYER

---------------------------------------------------------------------------------------------------------------------------------*/

DROP PROCEDURE IF EXISTS dwh_silver.sp_load_silver;									-- DROPPING IF ALREAD EXISTS

DELIMITER $$
CREATE PROCEDURE dwh_silver.sp_load_silver ()
BEGIN
	DECLARE v_start_time_global TIMESTAMP;										-- VARIABLE TO GET START TIME FOR WHOLE LOAD
	DECLARE v_start_time TIMESTAMP;												-- VARIABLE TO GET LOAD'S START TIME FOR EACH TABLE
    DECLARE v_end_time TIMESTAMP;												
    DECLARE v_error INT; 															
    DECLARE v_sqlstate CHAR(5);
    DECLARE v_msg TEXT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION							-- ERROR HANDLING
    BEGIN
		GET DIAGNOSTICS CONDITION 1
        v_error 	= MYSQL_ERRNO,
        v_sqlstate	= RETURNED_SQLSTATE,
        v_msg 		= MESSAGE_TEXT;
        
        INSERT INTO dwh_silver.load_error											-- INSERTING DATA IN LOAD_ERROR TABLE IF ANY ERROR OCCURED 
        (error_number, error_sqlstate, error_message, error_occured_at)
        VALUES(v_error,
			   v_sqlstate, 
               v_msg, 
               NOW()
        );
        
    END;
    
	 START TRANSACTION;																		-- TRANSACTION START
     
    SET v_start_time_global = NOW();
    
    	
	/* =======================================================================================================================================================================================
	 >>>>>>>>>> Inserting transformed data from bronze layer to silver layer <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	 
	===========================================================================================================================================================================================*/
	
	/*-------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.crm_cust_info to dwh_silver.crm_cust_info
	---------------------------------------------------------------------------------------*/
    /* ================= CUSTOMER TABLE ================= */

	SET v_start_time= NOW(); 
    
	TRUNCATE TABLE dwh_silver.crm_cust_info;
    
	INSERT INTO dwh_silver.crm_cust_info (
	cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	)
	SELECT 
    
	CASE WHEN cst_id REGEXP '^[0-9]+$' 
		THEN  CAST( cst_id AS unsigned)
		 ELSE NULL
	END as cst_id, 															-- Change cst_id datatype from VARCHAR() TO INT UNSIGNED
	cst_key,
	TRIM(cst_firstname) AS cst_firstname,									-- removing unwanted spaces
	TRIM(cst_lastname) AS cst_lastname,										-- removing unwanted spaces
	CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
		 WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
		 ELSE 'unknown'
	END AS cst_marital_status,									-- normalise marital status in readable format
	CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
		 WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
		 ELSE 'unknown'
	END AS cst_gndr,												-- normalise gender in readable format
	 
	CASE WHEN cst_create_date REGEXP '^[0-9]{4}[-\.][0-9]{2}[-/.][0-9]{2}'
		 THEN CAST(cst_create_date AS DATE)
		 WHEN cst_create_date REGEXP '^[0-9]{2}[-\.][0-9]{2}[-/.][0-9]{4}'
		 THEN STR_TO_DATE(cst_create_date, '%d-%m-%Y')
		 ELSE NULL
	END AS cst_create_date														-- Change cst_create_date datatype from VARCHAR() TO DATE
	FROM(
		SELECT *,
		ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
		FROM dwh_bronze.crm_cust_info
		WHERE cst_id !='')t
	WHERE flag=1																	-- Select the most recent record per customer
	;
	
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_cust_info Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
	/*-------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.crm_prd_info to dwh_silver.crm_prd_info
	---------------------------------------------------------------------------------------*/
	SET v_start_time= NOW(); 
    
	TRUNCATE TABLE dwh_silver.crm_prd_info;
    
	INSERT INTO dwh_silver.crm_prd_info (
	prd_id ,
	cat_id,
	prd_key,
	prd_nm ,
	prd_cost,
	prd_line ,
	prd_start_dt,
	prd_end_dt 
	)
	SELECT 
	CASE WHEN prd_id REGEXP '^[0-9]+$'															-- Casting to INT UNSIGNED datatype
		 THEN CAST(prd_id AS UNSIGNED)
		 ELSE NULL 
	END AS prd_id,

	REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,									-- extracting values from prd_key using replace() and substring() and new meta column as cat_id
	SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key,
	TRIM(prd_nm) AS prd_nm,
	CASE WHEN TRIM(prd_cost) REGEXP '^[0-9]+$'												-- Casting to INT UNSIGNED datatype
		 THEN CAST(TRIM(prd_cost) AS UNSIGNED)
		 ELSE '0' 
	END AS prd_cost,
	CASE UPPER(TRIM(prd_line))																-- Normalise prd_line category for better readability
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
		WHEN 'S' THEN 'Other Sales'
		WHEN 'T' THEN 'Touring'
		ELSE 'n/a'
	END AS prd_line,
	CASE WHEN prd_start_dt REGEXP '^[0-9]{4}[-/.][0-9]{2}[-/.][0-9]{2}' 					-- casting datatype from VARCHAR() to DATE
		 THEN CAST(prd_start_dt AS DATE)
		 WHEN prd_start_dt REGEXP '^[0-9]{2}[-/.][0-9]{2}[-/.][0-9]{4}'
		 THEN STR_TO_DATE(prd_start_dt, '%d-%m-%Y')
		 ELSE NULL
	END AS prd_start_dt,
	(LEAD (CASE WHEN prd_start_dt REGEXP '^[0-9]{4}[-/.][0-9]{2}[-/.][0-9]{2}'   			-- Using LEAD() beacuse input end date was smaller than the start date
		 THEN CAST(prd_start_dt AS DATE)													--  so making sure the end date should be bigger than start date
		 WHEN prd_start_dt REGEXP '^[0-9]{2}[-/.][0-9]{2}[-/.][0-9]{4}'
		 THEN STR_TO_DATE(prd_start_dt, '%d-%m-%Y')
		 ELSE NULL
		 END) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) - INTERVAL 1 DAY AS prd_end_dt
	FROM dwh_bronze.crm_prd_info
	;
    
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_prd_info Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;

	/*-------------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.crm_sales_details to dwh_silver.crm_sales_details
	--------------------------------------------------------------------------------------------*/

	SET v_start_time= NOW();
    
	TRUNCATE TABLE dwh_silver.crm_sales_details;

	INSERT INTO dwh_silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)
	SELECT 
	TRIM(sls_ord_num) AS sls_ord_num,
	TRIM(sls_prd_key) AS sls_prd_key,
	TRIM(sls_cust_id) AS sls_cust_id,
	CASE WHEN sls_order_dt IS NULL OR sls_order_dt=0  OR LENGTH(sls_order_dt)!=8 THEN NULL 
		 ELSE CAST(sls_order_dt AS DATE)
	END AS sls_order_dt,

	CASE WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt)!=8 THEN NULL 
		 ELSE CAST(sls_ship_dt AS DATE)
	END AS sls_ship_dt,

	CASE WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt)!=8 THEN NULL 
		 ELSE CAST(sls_due_dt AS DATE)
	END AS sls_due_dt,

	CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)																		
		 THEN sls_quantity *  (CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
								   ELSE sls_price END)
		ELSE  sls_sales
	END AS sls_sales,

	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 
		 THEN sls_sales / NULLIF(sls_quantity, 0)
		 ELSE sls_price 
	END AS sls_price
	FROM dwh_bronze.crm_sales_details
	;
	
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_sales_details Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
	/*-------------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.erp_cust_az12 to dwh_silver.erp_cust_az12
	--------------------------------------------------------------------------------------------*/
	
    SET v_start_time= NOW();
    
    TRUNCATE TABLE dwh_silver.erp_cust_az12;

	INSERT INTO dwh_silver.erp_cust_az12
	(
	cid,
	bdate,
	gen
	)
	SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
		 ELSE cid
	END AS cid,
	CASE WHEN bdate > NOW() THEN NULL 
		 ELSE CAST(bdate AS DATE)
	END AS bdate,
	CASE WHEN  NULLIF(UPPER(TRIM(REGEXP_REPLACE(gen,'[[:space:]]',''))),'') IN ('F', 'FEMALE') THEN 'Female'
		WHEN  NULLIF(UPPER(TRIM(REGEXP_REPLACE(gen,'[[:space:]]',''))),'') IN ('M','MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen
	FROM dwh_bronze.erp_cust_az12
	;
	SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_cust_az12 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
	/*-------------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.erp_loc_a101 to dwh_silver.erp_loc_a101
	--------------------------------------------------------------------------------------------*/
	SET v_start_time= NOW();
    
	TRUNCATE TABLE dwh_silver.erp_loc_a101;
    
	INSERT INTO dwh_silver.erp_loc_a101 (
	cid,
	cntry
	)
	SELECT
	REPLACE(cid,'-','') AS cid, 
	CASE WHEN UPPER(REGEXP_REPLACE(cntry, '[^A-Za-z]','')) IN ('US', 'USA', 'UNITEDSTATES') THEN 'United States'
		WHEN UPPER(REGEXP_REPLACE(cntry, '[^A-Za-z]',''))= 'DE' THEN 'Denmark'
		WHEN REGEXP_REPLACE(cntry, '[^A-Za-z]','') ='' THEN NULL 
		ELSE cntry
	END AS cntry
	FROM dwh_bronze.erp_loc_a101
	;
    
	SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_loc_a101 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;

	/*-------------------------------------------------------------------------------------------
	Inserting transformed data from dwh_bronze.erp_px_cat_g1v2 to dwh_silver.erp_px_cat_g1v2
	--------------------------------------------------------------------------------------------*/
	SET v_start_time= NOW();
    
	TRUNCATE TABLE dwh_silver.erp_px_cat_g1v2;

	INSERT INTO dwh_silver.erp_px_cat_g1v2 (
	id,
	cat,
	subcat,
	maintenance
	)
	SELECT 
	TRIM(id) AS id,
	TRIM(cat) AS cat,
	TRIM(subcat) AS subcat,
	CASE WHEN REGEXP_REPLACE(maintenance, '[^A-Za-z]','')='YES' THEN 'Yes'
		 ELSE 'No'
	END maintenance
	FROM dwh_bronze.erp_px_cat_g1v2
	;
	SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_px_cat_g1v2 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    SET v_end_time = NOW();
        
    SELECT CONCAT('Total load time : ', TIMESTAMPDIFF(SECOND, v_start_time_global, v_end_time), ' ', 'seconds') AS message;
    
    COMMIT ;
 END$$ 
 DELIMITER ;
 
 CALL dwh_silver.sp_load_silver();
 
 SELECT * FROM dwh_silver.erp_loc_a101;
 SELECT * FROM dwh_silver.load_error;