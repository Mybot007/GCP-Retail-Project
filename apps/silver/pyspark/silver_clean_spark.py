from pyspark.sql import SparkSession, functions as F

spark = (SparkSession.builder
         .appName("silver-clean")
         .getOrCreate())

src = "gs://retail-bronze-dev-raw/bronze/orders/*.csv"   # or BQ connector
df = (spark.read.option("header", True).csv(src)
      .withColumn("amount", F.col("amount").cast("double"))
      .withColumn("updated_at", F.to_timestamp("updated_at"))
      .dropDuplicates(["order_id"]))

(df.write.format("bigquery")
 .option("table", "retail-silver-dev.silver.orders_silver")
 .mode("overwrite")
 .save())
