# variable "billing_account" {
#   # put your Billing Account ID in terraform.tfvars or set via CLI/ENV
#   type = string
# }

# variable "folder_id" {
#   type    = string
#   default = null
# }

# module "bronze_project" {
#   source          = "../../modules/project"
#   project_id      = var.bronze_project # "retail-bronze-dev"
#   billing_account = var.billing_account
#   folder_id       = var.folder_id
# }

# module "silver_project" {
#   source          = "../../modules/project"
#   project_id      = var.silver_project # "retail-silver-dev"
#   billing_account = var.billing_account
#   folder_id       = var.folder_id
# }

# module "gold_project" {
#   source          = "../../modules/project"
#   project_id      = var.gold_project # "retail-gold-dev"
#   billing_account = var.billing_account
#   folder_id       = var.folder_id
# }
