/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'dwh_gold.dim_customer'
-- ====================================================================
-- Check for Uniqueness of Customer Key in dwh_gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM dwh_gold.dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'dwh_gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in dwh_gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM dwh_gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'dwh_gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM dwh_gold.fact_sales f
LEFT JOIN dwh_gold.dim_customer c
ON c.customer_key = f.customer_key
LEFT JOIN dwh_gold.dim_product p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  
