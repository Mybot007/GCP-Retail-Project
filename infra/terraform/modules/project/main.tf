terraform {
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

resource "google_project" "this" {
  project_id      = var.project_id
  name            = var.project_id
  billing_account = var.billing_account
  folder_id       = var.folder_id # omit if you don't use folders
}

# Enable APIs you need
locals {
  apis = [
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "dataflow.googleapis.com",
  ]
}

resource "google_project_service" "svc" {
  for_each           = toset(local.apis)
  project            = google_project.this.project_id
  service            = each.value
  disable_on_destroy = false
}

output "project_id" { value = google_project.this.project_id }
output "services_done" {
  value      = true
  depends_on = [google_project_service.svc]
}
