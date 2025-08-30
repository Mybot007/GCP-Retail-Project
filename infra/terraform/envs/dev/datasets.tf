# Single project holds all four datasets exactly once
# module "core_datasets" {
#   source     = "../../modules/bq_datasets"
#   project_id = var.bronze_project   # all three vars point to the same project in tfvars
#   datasets = [
#     { dataset_id = "bronze_dev",   location = var.region },
#     { dataset_id = "silver_dev",   location = var.region },
#     { dataset_id = "gold_dev",     location = var.region },
#     { dataset_id = "metadata_dev", location = var.region },
#   ]
# }


module "core_datasets" {
  source     = "../../modules/bq_datasets"
  project_id = var.project_id
  datasets = [
    { dataset_id = local.ds_bronze, location = var.region },
    { dataset_id = local.ds_silver, location = var.region },
    { dataset_id = local.ds_gold, location = var.region },
    { dataset_id = local.ds_meta, location = var.region },
  ]
}
