# variable "region" { default = "asia-south1" }
# variable "bronze_project" { default = "retail-bronze-dev" }
# variable "silver_project" { default = "retail-silver-dev" }
# variable "gold_project" { default = "retail-gold-dev" }


# variable "region" { default = "asia-south1" }
# variable "bronze_project" { type = string }
# variable "silver_project" { type = string }
# variable "gold_project" { type = string }

variable "project_id" { type = string } # single project
variable "region" { default = "asia-south1" }
variable "env" { default = "dev" }

# Namespacing helpers
locals {
  ds_bronze = "bronze_${var.env}"
  ds_silver = "silver_${var.env}"
  ds_gold   = "gold_${var.env}"
  ds_meta   = "metadata_${var.env}"

  bucket_raw = "retail-${var.env}-raw"
  bucket_cur = "retail-${var.env}-curated"
  repo_name  = "retail-${var.env}-containers"

  topic_orders = "orders-${var.env}-topic"
  sub_orders   = "orders-${var.env}-sub"
}
