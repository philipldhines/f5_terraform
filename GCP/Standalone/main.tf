# Main

# Terraform Version Pinning
terraform {
  required_version = "> 0.14"
  required_providers {
    google = "~> 3"
  }
}

# Google Provider
provider "google" {
  credentials = file("~/f5-terraform-344519-ee278f4242b4.json")

  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}
