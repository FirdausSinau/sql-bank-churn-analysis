-- Preview the full dataset as a starting point for exploration
SELECT * FROM cust_info_staging;

-- Compare the average characteristics of customers who churned vs. those who stayed
SELECT 
  churn,
  COUNT(*) customer_count,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cust_info_staging), 1) pct_of_total,
  ROUND(AVG(age), 1) avg_age,
  ROUND(AVG(credit_score), 1) avg_credit_score,
  ROUND(AVG(balance), 1) avg_balance,
  ROUND(AVG(products_number), 1) avg_products,
  ROUND(AVG(tenure), 1) avg_tenure,
  ROUND(SUM(active_member) * 100 / COUNT(*), 1) active_member_pct,
  ROUND(SUM(credit_card) * 100 / COUNT(*), 1) credit_card_pct,
  ROUND(AVG(estimated_salary), 1) avg_salary
FROM cust_info_staging
GROUP BY churn;

-- churn = 0 (Stayed)
-- churn = 1 (Churned)

SELECT 
  country,
  ROUND(SUM(
  CASE 
	WHEN active_member = 0 THEN 1 
	ELSE 0 
  END) * 100 / COUNT(*), 1) inactive_pct,
  ROUND(SUM(
  CASE
	WHEN active_member = 0 THEN churn 
    ELSE NULL 
END) * 100 / SUM(CASE
	WHEN active_member = 0 THEN 1 
    ELSE 0 
END), 1) churn_rate_inactive
FROM cust_info_staging
GROUP BY country;

