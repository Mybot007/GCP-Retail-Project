import os, pandas as pd
from google.cloud import bigquery

PROJECT = os.environ["PROJECT_ID"]          # retail-silver-dev
SRC = "retail-bronze-dev.bronze.orders_bronze"
DEST = f"{PROJECT}.silver.orders_silver"
META = f"{PROJECT}.metadata.audit_log"
LOAD_ID = os.environ.get("LOAD_ID", "adhoc")

def run():
    bq = bigquery.Client(project=PROJECT)
    df = bq.query(f"SELECT * FROM `{SRC}`").result().to_dataframe(create_bqstorage_client=True)
    src_count = len(df)

    # Cleaning
    df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0)
    df["updated_at"] = pd.to_datetime(df["updated_at"], utc=True)
    df = df.drop_duplicates(subset=["order_id"])

    job = bq.load_table_from_dataframe(df, DEST)
    job.result()
    bq.insert_rows_json(META, [{
        "load_id": LOAD_ID, "layer": "silver", "stage": "clean",
        "table_name": "orders_silver", "env": PROJECT.split("-")[-1],
        "src_count": src_count, "written_count": len(df),
        "checksum": "", "status": "SUCCESS"
    }])

if __name__ == "__main__":
    run()
