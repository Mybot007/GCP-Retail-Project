import os, time, hashlib, json, pandas as pd
from google.cloud import bigquery, storage
from datetime import datetime, timezone

PROJECT = os.environ["PROJECT_ID"]                # e.g. retail-bronze-dev
DATASET = "bronze"
METADATA = "metadata"
TABLE = "orders_bronze"
AUDIT = "audit_log"
RAW_BUCKET = os.environ["RAW_BUCKET"]             # e.g. retail-bronze-dev-raw
LOAD_ID = f"bronze_orders_{int(time.time())}"

def _hash_df(df: pd.DataFrame) -> str:
    m = hashlib.md5()
    m.update(pd.util.hash_pandas_object(df, index=True).values)
    return m.hexdigest()

def fetch_from_api() -> pd.DataFrame:
    # Simulated source; replace with real API call + pagination
    return pd.DataFrame([
        {"order_id": 1, "customer_id": 10, "amount": 99.5, "updated_at": "2025-08-01T10:00:00Z"},
        {"order_id": 2, "customer_id": 11, "amount": 12.3, "updated_at": "2025-08-01T11:30:00Z"},
    ])

def fetch_from_csv() -> pd.DataFrame:
    # Simulated second source; replace with GCS/S3/local read
    return pd.DataFrame([
        {"order_id": 3, "customer_id": 12, "amount": 24.0, "updated_at": "2025-08-02T09:00:00Z"},
    ])

def write_gcs(df: pd.DataFrame, key: str):
    storage.Client().bucket(RAW_BUCKET).blob(key).upload_from_string(
        df.to_csv(index=False), content_type="text/csv"
    )

def load_to_bq(df: pd.DataFrame):
    client = bigquery.Client(project=PROJECT)
    table_id = f"{PROJECT}.{DATASET}.{TABLE}"
    job = client.load_table_from_dataframe(df, table_id)
    job.result()

def write_audit(stage: str, src_count: int, written_count: int, checksum: str, status: str, err: str = None):
    client = bigquery.Client(project=PROJECT)
    table = f"{PROJECT}.{METADATA}.{AUDIT}"
    rows = [{
        "load_id": LOAD_ID, "layer": "bronze", "stage": stage,
        "table_name": TABLE, "env": PROJECT.split("-")[-1],
        "start_time": datetime.now(timezone.utc).isoformat(),
        "end_time": datetime.now(timezone.utc).isoformat(),
        "src_count": src_count, "written_count": written_count,
        "checksum": checksum, "status": status, "error": err
    }]
    client.insert_rows_json(table, rows)

def main():
    try:
        df = pd.concat([fetch_from_api(), fetch_from_csv()], ignore_index=True)
        checksum = _hash_df(df)
        key = f"orders/load_id={LOAD_ID}/orders.csv"
        write_gcs(df, key)                              # Archive raw drop
        load_to_bq(df)                                  # Minimal transform only
        write_audit("bronze_load", len(df), len(df), checksum, "SUCCESS")
    except Exception as e:
        write_audit("bronze_load", 0, 0, "", "FAILED", str(e))
        raise

if __name__ == "__main__":
    main()
