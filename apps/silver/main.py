import os
from google.cloud import bigquery

PROJECT_ID = os.getenv("PROJECT_ID")
SILVER_DATASET = os.getenv("SILVER_DATASET", "silver")
METADATA_DATASET = os.getenv("METADATA_DATASET", "metadata")

# Example no-op: create a dummy query so the container can run
def run():
    bq = bigquery.Client(project=PROJECT_ID)
    sql = f"SELECT CURRENT_TIMESTAMP() as ts"
    list(bq.query(sql).result())
    print("silver step ran")

if __name__ == "__main__":
    run()
