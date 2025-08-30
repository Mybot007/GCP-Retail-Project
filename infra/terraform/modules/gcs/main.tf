resource "google_storage_bucket" "b" {
  for_each                    = toset(var.bucket_names)
  name                        = each.value
  location                    = var.location
  uniform_bucket_level_access = true
  versioning { enabled = var.versioning }
  lifecycle_rule {
    action { type = "Delete" }
    condition { age = 30 } # tweak
  }
}
