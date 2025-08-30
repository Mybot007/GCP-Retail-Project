from pyspark.sql import SparkSession, functions as F

spark = SparkSession.builder.appName("gold-agg").getOrCreate()
df = spark.read.format("bigquery").option("table","retail-silver-dev.silver.orders_silver").load()
out = (df.groupBy(F.to_date("updated_at").alias("order_date"))
         .agg(F.count("*").alias("orders"), F.sum("amount").alias("revenue")))
(out.write.format("bigquery")
    .option("table", "retail-gold-dev.gold.order_revenue_daily")
    .mode("overwrite").save())
