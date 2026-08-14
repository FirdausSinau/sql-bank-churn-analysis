-- Preview the full dataset as a starting point for exploration
SELECT * FROM cust_info_staging;

-- Compare customer count, churn rate, and average characteristics across countries
SELECT 
  country,
  COUNT(*) total_customers,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cust_info_staging), 1) pct_of_base,
  SUM(churn) churned_count,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) churn_rate_pct,
  ROUND(AVG(age), 1) avg_age,
  ROUND(AVG(balance), 1) avg_balance,
  ROUND(AVG(tenure), 1) avg_tenure,
  ROUND(AVG(estimated_salary), 1) avg_salary,
  ROUND(AVG(products_number), 1) avg_products,
  ROUND(SUM(active_member) * 100 / COUNT(*), 1) active_member_pct
FROM cust_info_staging
GROUP BY country;

-- Drill down into German customers aged 40+ since they have the highest churn rate
SELECT 
    SUM(churn) churned_count,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) churn_rate_pct,
  ROUND(AVG(age), 1) avg_age,
  ROUND(AVG(balance), 1) avg_balance,
  ROUND(AVG(tenure), 1) avg_tenure,
  ROUND(AVG(estimated_salary), 1) avg_salary,
  ROUND(AVG(products_number), 1) avg_products,
  ROUND(SUM(active_member) * 100 / COUNT(*), 1) active_member_pct
FROM cust_info_staging
WHERE country = 'Germany' AND age >= 40
GROUP BY country;


