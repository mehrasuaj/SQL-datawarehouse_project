/* ==============================================================================================================================
 creating store procedure to load data for raw table to original tables for bronze layer

			>>>>>>>>>>> Start of Procedure <<<<<<<<<<<<<<<<<
==================================================================================================================================*/

DELIMITER $$
DROP PROCEDURE IF EXISTS load_bronze;
CREATE PROCEDURE load_bronze()
BEGIN
	DECLARE v_start_time_global TIMESTAMP;			-- Declared variable to get start time 
    DECLARE v_start_time TIMESTAMP;              	 -- Declared variable to get start time 
    DECLARE v_end_time   TIMESTAMP;  				 -- Declared variable to get end time 
    DECLARE v_sqlstate  CHAR(5);					 -- Declared variable to get sqlstate 5 character code 
    DECLARE v_errno     INT;						-- Declared variable to get error number 
    DECLARE v_msg       TEXT;						-- Declared variable to get erroe message
 
           --  Error Handling
           
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            v_sqlstate = RETURNED_SQLSTATE,
            v_errno    = MYSQL_ERRNO,
            v_msg      = MESSAGE_TEXT;

        INSERT INTO dwh_bronze.load_error				-- Inserting error details in table load_error_logs
        (
            error_number,
            error_sqlstate,
            error_message,
            error_occured_at
		)
        VALUES
        (
            v_errno,
            v_sqlstate,
            v_msg,
            NOW()
        );
	END;

    SET v_start_time_global = NOW();								-- getting start time
    
    /*===================================================================================================================================
				>>>>>>>>> Inserting data from raw table to original table.  <<<<<<<<<<<<
    =====================================================================================================================================*/
    
    -- Inserting data from crm_cust_info_raw table to crm_cust_info
     SET v_start_time= NOW();
	TRUNCATE TABLE dwh_bronze.crm_cust_info;
    INSERT INTO dwh_bronze.crm_cust_info
    SELECT *
    FROM dwh_bronze.crm_cust_info_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_cust_info Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
     -- Inserting data from crm_prd_info_raw table to crm_prd_info
     SET v_start_time= NOW();
    TRUNCATE TABLE dwh_bronze.crm_prd_info;
    INSERT INTO dwh_bronze.crm_prd_info
    SELECT *
    FROM dwh_bronze.crm_prd_info_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_prd_info Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    -- Inserting data from crm_sales_details_raw table to crm_sales_details
    SET v_start_time= NOW();
    TRUNCATE TABLE dwh_bronze.crm_sales_details;
    INSERT INTO dwh_bronze.crm_sales_details
    SELECT *
    FROM dwh_bronze.crm_sales_details_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'crm_sales_details Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    -- Inserting data from erp_cust_az12_raw table to erp_cust_az12
    SET v_start_time= NOW();
	TRUNCATE TABLE dwh_bronze.erp_cust_az12;
    INSERT INTO dwh_bronze.erp_cust_az12
    SELECT *
    FROM dwh_bronze.erp_cust_az12_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_cust_az12 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    -- Inserting data from erp_loc_a101_raw table to erp_loc_a101
    SET v_start_time= NOW();
    TRUNCATE TABLE dwh_bronze.erp_loc_a101;
    INSERT INTO dwh_bronze.erp_loc_a101
    SELECT *
    FROM dwh_bronze.erp_loc_a101_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_loc_a101 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    -- Inserting data from erp_px_cat_g1v2_raw table to erp_px_cat_g1v2
    SET v_start_time= NOW();
    TRUNCATE TABLE dwh_bronze.erp_px_cat_g1v2;
    INSERT INTO dwh_bronze.erp_px_cat_g1v2
    SELECT *
    FROM dwh_bronze.erp_px_cat_g1v2_raw;
    SET v_end_time = NOW();
    SELECT CONCAT('Rows Inserted: ', ROW_COUNT(),' : ', 'erp_px_cat_g1v2 Load Time: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time),' seconds') AS status;
    
    SET v_end_time = NOW();
    
    SELECT CONCAT('Total loading time: ', TIMESTAMPDIFF(SECOND, v_start_time_global, v_end_time), ' ', 'seconds') AS message;  -- getting run time in output message

END$$

DELIMITER ;

/* ===================================================================================================================================
		********************************* END OF PROCEDURE****************************************************
======================================================================================================================================*/

CALL load_bronze();                 			-- calling store procedure

SELECT * FROM dwh_bronze.crm_prd_info; 					-- rechecking the stored table data
SELECT COUNT(*) FROM dwh_bronze.crm_prd_info_raw;

SELECT * FROM dwh_bronze.load_error; 		 		-- checking if any error stored in the table

SELECT * FROM dwh_bronze.crm_cust_info;					-- rechecking the stored table data
SELECT COUNT(*) FROM dwh_bronze.crm_cust_info_raw;

SELECT * FROM dwh_bronze.erp_cust_az12;					-- rechecking the stored table data
SELECT COUNT(*) FROM dwh_bronze.erp_cust_az12_raw;
