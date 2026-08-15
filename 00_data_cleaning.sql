-- Create a staging table so the raw data stays untouched during cleaning
CREATE TABLE `cust_info_staging` (
  `customer_id` int DEFAULT NULL,
  `credit_score` int DEFAULT NULL,
  `country` text,
  `gender` text,
  `age` double DEFAULT NULL,
  `tenure` bigint DEFAULT NULL,
  `balance` double DEFAULT NULL,
  `products_number` double DEFAULT NULL,
  `credit_card` int DEFAULT NULL,
  `active_member` double DEFAULT NULL,
  `estimated_salary` double DEFAULT NULL,
  `churn` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Inserting raw data into staging table
INSERT cust_info_staging
SELECT * FROM cust_info;

SELECT * FROM cust_info_staging;

-- 1. Check for duplicates
-- Compare unique rows against the total row count to detect duplicates
SELECT COUNT(*) total_cust FROM cust_info_staging;
SELECT DISTINCT customer_id FROM cust_info_staging;

-- 2. Standardize data
-- Check the value variations in the country column before cleaning + Trim to remove whitespace
SELECT DISTINCT country FROM cust_info_staging;
SELECT TRIM(country) FROM cust_info_staging;
UPDATE cust_info_staging
SET country = TRIM(country);

-- Check the value variations in the gender column before cleaning + Trim to remove whitespace
SELECT DISTINCT gender FROM cust_info_staging;
SELECT TRIM(gender) FROM cust_info_staging;
UPDATE cust_info_staging
SET gender = TRIM(gender);

-- 3. Null/blank values/outlier
-- Confirm the gender column only contains valid categories
SELECT DISTINCT gender FROM cust_info_staging;

-- Confirm the column only contains 0 or 1
SELECT DISTINCT credit_card FROM cust_info_staging;
SELECT DISTINCT active_member FROM cust_info_staging;
SELECT DISTINCT churn FROM cust_info_staging;

-- Check customers with age outside a reasonable range
SELECT * FROM cust_info_staging
WHERE age < 18;

-- Check customers with invalid values
SELECT * FROM cust_info_staging
WHERE tenure < 0 OR products_number <= 0;

-- Check every column at once for NULL values
SELECT 
  SUM(customer_id IS NULL),
  SUM(credit_score IS NULL),
  SUM(country IS NULL),
  SUM(gender IS NULL),
  SUM(age IS NULL),
  SUM(tenure IS NULL),
  SUM(balance IS NULL),
  SUM(products_number IS NULL),
  SUM(credit_card IS NULL),
  SUM(active_member IS NULL),
  SUM(estimated_salary IS NULL),
  SUM(churn IS NULL)
FROM cust_info_staging;

-- Check whether the column has any blank string values
SELECT 
  SUM(country IS NULL OR country = ''),
  SUM(gender IS NULL OR gender = '')
FROM cust_info_staging;

