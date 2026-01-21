
USE dwh_bronze;

-- =================================================================================================
--  LOADING SOURCE CSV FILES (CRM + ERP) INTO THE BRONZE DATABASE
-- =================================================================================================

SET @v_start_time = NOW();

-- ---------------------------------------------------------------------------------
-- CRM: Customer Info
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.crm_cust_info_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE dwh_bronze.crm_cust_info_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;


-- ---------------------------------------------------------------------------------
-- CRM: Product Info
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.crm_prd_info_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE dwh_bronze.crm_prd_info_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;

-- ---------------------------------------------------------------------------------
-- CRM: Sales Details
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.crm_sales_details_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE dwh_bronze.crm_sales_details_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;

-- ---------------------------------------------------------------------------------
-- ERP: Customer
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.erp_cust_az12_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_az12.csv'
INTO TABLE dwh_bronze.erp_cust_az12_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
@cid,
@bdate,
@gen
)
SET 
cid=@cid,
bdate=@bdate,
gen=@gen
;

-- ---------------------------------------------------------------------------------
-- ERP: Location
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.erp_loc_a101_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/loc_a101.csv'
INTO TABLE dwh_bronze.erp_loc_a101_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;

-- ---------------------------------------------------------------------------------
-- ERP: Product Category
-- ---------------------------------------------------------------------------------
TRUNCATE TABLE dwh_bronze.erp_px_cat_g1v2_raw;

LOAD DATA INFILE
    'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/px_cat_g1v2.csv'
INTO TABLE dwh_bronze.erp_px_cat_g1v2_raw
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
;
SET @v_end_time = NOW();
-- ---------------------------------------------------------------------------------
-- Load Time
SELECT CONCAT('>> Total loading time: ',TIMESTAMPDIFF(SECOND, @v_start_time, @v_end_time),' seconds') AS message;




