resource "google_bigquery_dataset" "ds" {
  for_each   = { for d in var.datasets : d.id => d }
  dataset_id = each.key
  location   = each.value.location
}
