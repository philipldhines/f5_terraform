# Main

# Terraform Version Pinning
terraform {
  required_version = "> 0.14"
  required_providers {
    aws = "~> 3"
  }
}

# AWS Provider
provider "aws" {
  region     = var.awsRegion
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a random id
resource "random_id" "buildSuffix" {
  byte_length = 2
}
