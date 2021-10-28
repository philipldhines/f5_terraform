# Main

# Terraform Version Pinning
terraform {
  required_version = ">= 1.0.9"
  required_providers {
    google = ">= 3.90"
  }
}

# Google Provider
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}
