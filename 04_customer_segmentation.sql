SELECT 
  CASE 
    WHEN tenure >= 6 AND balance > 100000 AND products_number >= 2 AND active_member = 1 THEN 'Loyal'
    WHEN active_member = 0 THEN 'Non-Active'
    WHEN tenure >= 4 AND balance > 50000 THEN 'Established'
    WHEN tenure <= 2 AND balance <= 50000 THEN 'At-Risk'
    ELSE 'Regular'
  END AS segment,
  COUNT(*) total_customers,
  ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM cust_info_staging), 1) pct_of_total,
  SUM(churn) churned,
  ROUND(SUM(churn) * 100 / COUNT(*), 1) churn_rate_pct,
  ROUND(AVG(age), 1) avg_age,
  ROUND(AVG(balance), 1) avg_balance,
  ROUND(AVG(tenure), 1) avg_tenure,
  ROUND(AVG(products_number), 1) avg_products
FROM cust_info_staging
GROUP BY segment
ORDER BY churn_rate_pct;

