CREATE OR REPLACE TABLE `retail-silver-dev.silver.orders_silver` AS
SELECT
  CAST(order_id AS INT64) AS order_id,
  CAST(customer_id AS INT64) AS customer_id,
  SAFE_CAST(amount AS NUMERIC) AS amount,
  TIMESTAMP(updated_at) AS updated_at
FROM `retail-bronze-dev.bronze.orders_bronze`
QUALIFY ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY updated_at DESC) = 1;
