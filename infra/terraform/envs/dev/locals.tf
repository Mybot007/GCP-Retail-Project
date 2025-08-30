# locals {
#   labels_common = { env = "dev", domain = "retail" }

#   bronze_tables = [
#     {
#       dataset_id  = "bronze"
#       table_id    = "orders_bronze"
#       description = "Raw orders"
#       labels      = merge(local.labels_common, { layer = "bronze" })
#       schema      = file("${path.module}/../../schemas/bronze/orders_bronze.json")
#       partitioning = {
#         type                     = "DAY"
#         require_partition_filter = true
#       }
#       clustering = ["order_id"]
#     }
#   ]

#   metadata_tables_bronze = [
#     {
#       dataset_id   = "metadata"
#       table_id     = "audit_log"
#       description  = "Per-stage metrics"
#       labels       = merge(local.labels_common, { layer = "bronze" })
#       schema       = file("${path.module}/../../schemas/metadata/audit_log.json")
#       partitioning = { type = "DAY", field = "start_time" }
#       clustering   = ["layer", "stage", "table_name"]
#     },
#     {
#       dataset_id   = "metadata"
#       table_id     = "watermarks"
#       description  = "High-watermarks"
#       labels       = merge(local.labels_common, { layer = "bronze" })
#       schema       = file("${path.module}/../../schemas/metadata/watermarks.json")
#       partitioning = { type = "DAY", field = "updated_at" }
#     }
#   ]

#   silver_tables = [
#     {
#       dataset_id   = "silver"
#       table_id     = "orders_silver"
#       description  = "Cleaned orders"
#       labels       = merge(local.labels_common, { layer = "silver" })
#       schema       = file("${path.module}/../../schemas/silver/orders_silver.json")
#       partitioning = { type = "DAY", field = "updated_at" }
#       clustering   = ["order_id", "customer_id"]
#     }
#   ]

#   gold_tables = [
#     {
#       dataset_id   = "gold"
#       table_id     = "order_revenue_daily"
#       description  = "Daily revenue aggregates"
#       labels       = merge(local.labels_common, { layer = "gold" })
#       schema       = file("${path.module}/../../schemas/gold/order_revenue_daily.json")
#       partitioning = { type = "DAY", field = "order_date" }
#     }
#   ]
# }


locals {
  labels_common = { env = var.env, domain = "retail" }

  bronze_tables = [
    {
      dataset_id   = local.ds_bronze
      table_id     = "orders_bronze"
      description  = "Raw orders"
      labels       = merge(local.labels_common, { layer = "bronze" })
      schema       = file("${path.module}/../../schemas/bronze/orders_bronze.json")
      partitioning = { type = "DAY", require_partition_filter = true }
      clustering   = ["order_id"]
    }
  ]

  metadata_tables_bronze = [
    {
      dataset_id   = local.ds_meta
      table_id     = "audit_log"
      description  = "Per-stage metrics"
      labels       = merge(local.labels_common, { layer = "bronze" })
      schema       = file("${path.module}/../../schemas/metadata/audit_log.json")
      partitioning = { type = "DAY", field = "start_time" }
      clustering   = ["layer", "stage", "table_name"]
    },
    {
      dataset_id   = local.ds_meta
      table_id     = "watermarks"
      description  = "High-watermarks"
      labels       = merge(local.labels_common, { layer = "bronze" })
      schema       = file("${path.module}/../../schemas/metadata/watermarks.json")
      partitioning = { type = "DAY", field = "updated_at" }
    }
  ]

  silver_tables = [
    {
      dataset_id   = local.ds_silver
      table_id     = "orders_silver"
      description  = "Cleaned orders"
      labels       = merge(local.labels_common, { layer = "silver" })
      schema       = file("${path.module}/../../schemas/silver/orders_silver.json")
      partitioning = { type = "DAY", field = "updated_at" }
      clustering   = ["order_id", "customer_id"]
    }
  ]

  gold_tables = [
    {
      dataset_id   = local.ds_gold
      table_id     = "order_revenue_daily"
      description  = "Daily revenue aggregates"
      labels       = merge(local.labels_common, { layer = "gold" })
      schema       = file("${path.module}/../../schemas/gold/order_revenue_daily.json")
      partitioning = { type = "DAY", field = "order_date" }
    }
  ]
}
