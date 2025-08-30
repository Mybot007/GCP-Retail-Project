# module "bronze_tables" {
#   source     = "../../modules/bigquery_tables"
#   project_id = var.bronze_project
#   tables     = concat(local.bronze_tables, local.metadata_tables_bronze)
#   depends_on = [ module.core_datasets ]  # ensure datasets exist first
# }

# module "silver_tables" {
#   source     = "../../modules/bigquery_tables"
#   project_id = var.silver_project
#   tables     = local.silver_tables
#   depends_on = [ module.core_datasets ]
# }

# module "gold_tables" {
#   source     = "../../modules/bigquery_tables"
#   project_id = var.gold_project
#   tables     = local.gold_tables
#   depends_on = [ module.core_datasets ]
# }


module "bronze_tables" {
  source     = "../../modules/bigquery_tables"
  project_id = var.project_id
  tables     = concat(local.bronze_tables, local.metadata_tables_bronze)
  depends_on = [module.core_datasets]
}

module "silver_tables" {
  source     = "../../modules/bigquery_tables"
  project_id = var.project_id
  tables     = local.silver_tables
  depends_on = [module.core_datasets]
}

module "gold_tables" {
  source     = "../../modules/bigquery_tables"
  project_id = var.project_id
  tables     = local.gold_tables
  depends_on = [module.core_datasets]
}
