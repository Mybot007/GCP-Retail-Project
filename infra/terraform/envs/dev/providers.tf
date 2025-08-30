terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
  # If you use a remote backend (GCS), uncomment and set your bucket
  # backend "gcs" {
  #   bucket = "tfstate-retail-dev"
  #   prefix = "state/dev"
  # }
}

provider "google" {
  # When using modules that specify project_id explicitly, this can be minimal.
  # Optionally set region/zone defaults here.
}
