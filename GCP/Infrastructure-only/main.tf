# Main

# Terraform Version Pinning
terraform {
  required_version = ">= 0.14.5"
  required_providers {
    google = ">= 4"
  }
}

# Google Provider
provider "google" {
 credentials = file("~/f5-terraform-344519-ee278f4242b4.json")


  project = var.gcp_project_id
  region  = var.gcp_region
}

# Storage Bucket
resource "google_storage_bucket" "main" {
  name          = "${var.prefix}-storage"
  location      = "US"
  force_destroy = true
  labels = {
    f5_cloud_failover_label = var.f5_cloud_failover_label
  }
}
