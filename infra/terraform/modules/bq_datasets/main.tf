terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

resource "google_bigquery_dataset" "ds" {
  for_each    = { for d in var.datasets : d.dataset_id => d }
  project     = var.project_id
  dataset_id  = each.value.dataset_id
  location    = each.value.location
  description = try(each.value.description, null)
  labels      = try(each.value.labels, {})

  default_table_expiration_ms     = try(each.value.default_table_expiration_ms, null)
  default_partition_expiration_ms = try(each.value.default_partition_expiration_ms, null)

  dynamic "access" {
    for_each = try(each.value.access, [])
    content {
      role       = access.value.role       # READER/WRITER/OWNER (dataset-level roles)
      iam_member = access.value.iam_member # "serviceAccount:..."
    }
  }
}
