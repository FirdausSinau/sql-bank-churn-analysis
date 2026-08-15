-- Preview the full dataset as a starting point for exploration
SELECT * FROM cust_info_staging;

-- Calculate overall customer demographics: count, countries, age, credit score, balance, products, and churn rate
SELECT 
  COUNT(*) total_customers,
  COUNT(DISTINCT country) num_countries,
  ROUND(AVG(age), 1) avg_age,
  MIN(age) min_age,
  MAX(age) max_age,
  ROUND(AVG(credit_score), 1) avg_credit_score,
  ROUND(AVG(balance), 1) avg_balance,
  ROUND(AVG(products_number), 1) avg_products_per_customer,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) overall_churn_rate_pct,
  ROUND(SUM(active_member) * 100 / COUNT(*), 1) active_member_pct
FROM cust_info_staging;

-- Group customers into age brackets, then check the percentage, churn rate, and active rate per bracket
SELECT 
  CASE 
    WHEN age < 30 THEN '18-29'
    WHEN age < 40 THEN '30-39'
    WHEN age < 50 THEN '40-49'
    WHEN age < 60 THEN '50-59'
    ELSE '60+'
  END AS age_bracket,
  COUNT(*) count,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cust_info_staging), 1) pct,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) churn_rate_pct,
  ROUND(SUM(active_member) * 100 / COUNT(*), 1) active_member_pct
FROM cust_info_staging
GROUP BY age_bracket
ORDER BY age_bracket;

-- Check the customer count, churn, and percentage by gender
SELECT
  gender,
  COUNT(*) count,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cust_info_staging), 1) pct,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) churn_rate_pct
FROM cust_info_staging
GROUP BY gender;

-- Gender by country
SELECT country, gender, COUNT(*) count, ROUND(SUM(churn)*100/COUNT(*),1) churn_rate_pct
FROM cust_info_staging
GROUP BY country, gender;

-- Gender by age bracket
SELECT 
  CASE 
    WHEN age < 30 THEN '18-29'
    WHEN age < 40 THEN '30-39'
    WHEN age < 50 THEN '40-49'
    WHEN age < 60 THEN '50-59'
    ELSE '60+'
  END AS age_bracket,
  gender,
  COUNT(*) count,
  ROUND(SUM(churn)*100/COUNT(*),1) churn_rate_pct
FROM cust_info_staging
GROUP BY age_bracket, gender
ORDER BY age_bracket, gender;

