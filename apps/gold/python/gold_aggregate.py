import os
from google.cloud import bigquery

PROJECT = os.environ["PROJECT_ID"]          # retail-gold-dev
SRC = "retail-silver-dev.silver.orders_silver"
DEST = f"{PROJECT}.gold.order_revenue_daily"

SQL = f"""
CREATE OR REPLACE TABLE `{DEST}` PARTITION BY DATE(order_date) AS
SELECT
  DATE(updated_at) AS order_date,
  COUNT(*) AS orders,
  SUM(amount) AS revenue
FROM `{SRC}`
GROUP BY 1
"""

if __name__ == "__main__":
    bigquery.Client(project=PROJECT).query(SQL).result()
