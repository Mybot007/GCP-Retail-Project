# apps/bronze/main.py
import os
from google.cloud import bigquery, storage, pubsub_v1
import pandas as pd

PROJECT_ID       = os.getenv("PROJECT_ID")
BRONZE_DATASET   = os.getenv("BRONZE_DATASET")
SILVER_DATASET   = os.getenv("SILVER_DATASET")
METADATA_DATASET = os.getenv("METADATA_DATASET")
RAW_BUCKET       = os.getenv("RAW_BUCKET")

bq = bigquery.Client(project=PROJECT_ID)
gcs = storage.Client(project=PROJECT_ID)

def write_audit(load_id, layer, stage, table_name, env, start_time, end_time, src_count, written_count, status, error=None):
    table = f"{PROJECT_ID}.{METADATA_DATASET}.audit_log"
    rows = [{
        "load_id": load_id, "layer": layer, "stage": stage, "table_name": table_name, "env": env,
        "start_time": start_time, "end_time": end_time, "src_count": src_count,
        "written_count": written_count, "status": status, "error": error
    }]
    errors = bq.insert_rows_json(table, rows)
    if errors:
        raise RuntimeError(errors)

def load_orders_to_bronze(path_in_bucket: str):
    uri = f"gs://{RAW_BUCKET}/{path_in_bucket}"
    table = f"{PROJECT_ID}.{BRONZE_DATASET}.orders_bronze"
    job = bq.load_table_from_uri(
        uri, table,
        job_config=bigquery.LoadJobConfig(
            source_format=bigquery.SourceFormat.CSV,
            skip_leading_rows=1,
            write_disposition="WRITE_APPEND",
        ),
    )
    job.result()
    return bq.get_table(table).num_rows

if __name__ == "__main__":
    # Example run (Cloud Run Job will call this)
    count = load_orders_to_bronze("orders_2025-08-29.csv")
    print(f"Loaded {count} rows into bronze.orders_bronze")
