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

-- 1. Check for duplicates
-- Count the total number of rows
SELECT COUNT(*) total_cust FROM cust_info_staging;
-- Compare unique rows against the total row count to detect duplicates
SELECT DISTINCT * FROM cust_info_staging;

-- 2. Standardize data
-- Check the value variations in the country column before cleaning
SELECT DISTINCT country FROM cust_info_staging;
-- Preview the result after trimming extra whitespace
SELECT TRIM(country) FROM cust_info_staging;
-- Remove leading/trailing whitespace from the country column
UPDATE cust_info_staging
SET country = TRIM(country);

-- Check the value variations in the gender column before cleaning
SELECT DISTINCT gender FROM cust_info_staging;
-- Preview the result after trimming extra whitespace
SELECT TRIM(gender) FROM cust_info_staging;
-- Remove leading/trailing whitespace from the gender column
UPDATE cust_info_staging
SET gender = TRIM(gender);

-- 3. Null/blank values/anomalies
-- Confirm the gender column only contains valid categories
SELECT DISTINCT gender FROM cust_info_staging;

-- Confirm the credit_card column only contains 0 or 1
SELECT DISTINCT credit_card FROM cust_info_staging;

-- Confirm the active_member column only contains 0 or 1
SELECT DISTINCT active_member FROM cust_info_staging;

-- Confirm the churn column only contains 0 or 1
SELECT DISTINCT churn FROM cust_info_staging;

-- Check customers with tenure above 10 years as a potential outlier
SELECT * FROM cust_info_staging
WHERE tenure > 10;

-- Check customers with age outside a reasonable range (below 18 or above 100)
SELECT * FROM cust_info_staging
WHERE age < 18 OR age > 100;

-- Check customers with negative tenure or products_number of 0 or less (invalid values)
SELECT * FROM cust_info_staging
WHERE tenure < 0 OR products_number <= 0;

-- customer_id, credit_score, country, gender, age, tenure, balance,
-- products_number, credit_card, active_member, estimated_salary, churn
-- Check whether the churn column has any NULL values
SELECT * FROM cust_info_staging
WHERE churn IS NULL;

-- Preview churn = 0 records as part of checking the value distribution
SELECT * FROM cust_info_staging
WHERE churn = 0;

-- Check whether the churn column has any blank string values
SELECT * FROM cust_info_staging
WHERE churn = '';