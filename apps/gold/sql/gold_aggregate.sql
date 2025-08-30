CREATE OR REPLACE TABLE `retail-gold-dev.gold.order_revenue_daily` PARTITION BY DATE(order_date) AS
SELECT
  DATE(updated_at) AS order_date,
  COUNT(*) AS orders,
  SUM(amount) AS revenue
FROM `retail-silver-dev.silver.orders_silver`
GROUP BY 1;
