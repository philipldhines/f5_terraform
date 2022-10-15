# Main

# Terraform Version Pinning
terraform {
  required_version = ">= 0.14.5"
  required_providers {
    google = ">= 3"
  }
}

# Google Provider
provider "google" {
  credentials = file("~/f5-terraform-344519-ee278f4242b4.json")
  
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Create a random id
resource "random_id" "buildSuffix" {
  byte_length = 2
}
