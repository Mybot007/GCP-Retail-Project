# Buckets
resource "google_storage_bucket" "raw" {
  name                        = local.bucket_raw
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.labels_common
}

resource "google_storage_bucket" "curated" {
  name                        = local.bucket_cur
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
  labels                      = local.labels_common
}

# Artifact Registry (Docker)
resource "google_artifact_registry_repository" "repo" {
  project       = var.project_id
  location      = var.region
  repository_id = local.repo_name
  format        = "DOCKER"
  labels        = local.labels_common
}

# Service Account for Cloud Run Jobs
resource "google_service_account" "runner" {
  project      = var.project_id
  account_id   = "retail-${var.env}-runner"
  display_name = "Retail ${var.env} Runner"
}

# IAM for SA (BigQuery + GCS + Pub/Sub minimal)
resource "google_project_iam_member" "sa_bq_admin" {
  project = var.project_id
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "sa_storage" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

resource "google_project_iam_member" "sa_pubsub" {
  project = var.project_id
  role    = "roles/pubsub.editor"
  member  = "serviceAccount:${google_service_account.runner.email}"
}

# Pub/Sub
resource "google_pubsub_topic" "orders" {
  name    = local.topic_orders
  project = var.project_id
  labels  = local.labels_common
}

resource "google_pubsub_subscription" "orders" {
  name                 = local.sub_orders
  project              = var.project_id
  topic                = google_pubsub_topic.orders.name
  ack_deadline_seconds = 30

  dead_letter_policy {
    # full resource name, e.g. "projects/<proj>/topics/<topic>"
    dead_letter_topic     = google_pubsub_topic.orders.id
    max_delivery_attempts = 5
  }
}

# Cloud Run job definitions (images built by GitHub Actions or Cloud Build)
resource "google_cloud_run_v2_job" "bronze_load" {
  name     = "bronze-${var.env}-load"
  project  = var.project_id
  location = var.region

  template {
    template {
      service_account = google_service_account.runner.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${local.repo_name}/bronze:latest"

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "RAW_BUCKET"
          value = google_storage_bucket.raw.name
        }
        env {
          name  = "BRONZE_DATASET"
          value = local.ds_bronze
        }
        env {
          name  = "METADATA_DATASET"
          value = local.ds_meta
        }
      }
    }
  }

  depends_on = [
    module.core_datasets,
    google_storage_bucket.raw,
    google_artifact_registry_repository.repo
  ]
}

resource "google_cloud_run_v2_job" "silver_clean" {
  name     = "silver-${var.env}-clean"
  project  = var.project_id
  location = var.region

  template {
    template {
      service_account = google_service_account.runner.email

      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${local.repo_name}/silver:latest"

        env {
          name  = "PROJECT_ID"
          value = var.project_id
        }
        env {
          name  = "SILVER_DATASET"
          value = local.ds_silver
        }
        env {
          name  = "METADATA_DATASET"
          value = local.ds_meta
        }
      }
    }
  }

  depends_on = [
    module.core_datasets,
    google_artifact_registry_repository.repo
  ]
}
