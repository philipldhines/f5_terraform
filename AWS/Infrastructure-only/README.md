# Deploying Infrastructure-Only in AWS

## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Important Configuration Notes](#important-configuration-notes)
- [Installation Example](#installation-example)

## Introduction

This solution uses a Terraform template to launch a new networking stack. It will create one VPC with three subnets: mgmt, external, internal. Use this Terraform template to create your AWS VPC infrastructure, and then head back to the [BIG-IP AWS Terraform folder](../) to get started!

Terraform is beneficial as it allows composing resources a bit differently to account for dependencies into Immutable/Mutable elements. For example, mutable includes items you would typically frequently change/mutate, such as traditional configs on the BIG-IP. Once the template is deployed, there are certain resources (network infrastructure) that are fixed while others (BIG-IP VMs and configurations) can be changed.

## Prerequisites

- This template requires programmatic API credentials to deploy the Terraform AWS provider and build out all the neccessary AWS objects
  - See the [Terraform "AWS Provider"](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) for details
  - You will require at minimum `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
  - ***Note***: Make sure to [practice least privilege](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## Important Configuration Notes

- Variables are configured in variables.tf
- Sensitive variables like AWS SSH keys are configured in terraform.tfvars
- Files
  - main.tf - resources for provider, versions
  - network.tf - resources for VPC, subnets, route tables, internet gateway, security groups
<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_route_table_association.mgmtAz1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.mgmtAz2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.mgmtAz3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.mgmt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.mgmtAz1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.mgmtAz2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.mgmtAz3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [random_id.buildSuffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_awsAz1"></a> [awsAz1](#input\_awsAz1) | Availability zone, will dynamically choose one if left empty | `string` | `null` | no |
| <a name="input_awsAz2"></a> [awsAz2](#input\_awsAz2) | Availability zone, will dynamically choose one if left empty | `string` | `null` | no |
| <a name="input_awsAz3"></a> [awsAz3](#input\_awsAz3) | Availability zone, will dynamically choose one if left empty | `string` | `null` | no |
| <a name="input_awsRegion"></a> [awsRegion](#input\_awsRegion) | aws region | `string` | `"us-west-2"` | no |
| <a name="input_projectPrefix"></a> [projectPrefix](#input\_projectPrefix) | prefix for resources | `string` | `"myDemo"` | no |
| <a name="input_resourceOwner"></a> [resourceOwner](#input\_resourceOwner) | owner of the deployment, for tagging purposes | `string` | `"myName"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group_external"></a> [security\_group\_external](#output\_security\_group\_external) | ID of External security group |
| <a name="output_security_group_internal"></a> [security\_group\_internal](#output\_security\_group\_internal) | ID of Internal security group |
| <a name="output_security_group_mgmt"></a> [security\_group\_mgmt](#output\_security\_group\_mgmt) | ID of Management security group |
| <a name="output_subnets_external_az1"></a> [subnets\_external\_az1](#output\_subnets\_external\_az1) | ID of External subnets AZ1 |
| <a name="output_subnets_external_az2"></a> [subnets\_external\_az2](#output\_subnets\_external\_az2) | ID of External subnets AZ2 |
| <a name="output_subnets_external_az3"></a> [subnets\_external\_az3](#output\_subnets\_external\_az3) | ID of External subnets AZ3 |
| <a name="output_subnets_internal_az1"></a> [subnets\_internal\_az1](#output\_subnets\_internal\_az1) | ID of Internal subnets AZ1 |
| <a name="output_subnets_internal_az2"></a> [subnets\_internal\_az2](#output\_subnets\_internal\_az2) | ID of Internal subnets AZ2 |
| <a name="output_subnets_internal_az3"></a> [subnets\_internal\_az3](#output\_subnets\_internal\_az3) | ID of Internal subnets AZ3 |
| <a name="output_subnets_management_az1"></a> [subnets\_management\_az1](#output\_subnets\_management\_az1) | ID of Management subnets AZ1 |
| <a name="output_subnets_management_az2"></a> [subnets\_management\_az2](#output\_subnets\_management\_az2) | ID of Management subnets AZ2 |
| <a name="output_subnets_management_az3"></a> [subnets\_management\_az3](#output\_subnets\_management\_az3) | ID of Management subnets AZ3 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->

## Installation Example

To run this Terraform template, perform the following steps:
  1. Clone the repo to your favorite location
  2. Update AWS credentials
  ```
      export AWS_ACCESS_KEY_ID=<your-access-keyId>
      export AWS_SECRET_ACCESS_KEY=<your-secret-key>
  ```
  3. Modify terraform.tfvars with the required information
  ```
      awsRegion     = "us-west-2"
      projectPrefix = "myDemo"
      resourceOwner = "myName"
  ```
  4. Initialize the directory
  ```
      terraform init
  ```
  5. Test the plan and validate errors
  ```
      terraform plan
  ```
  6. Finally, apply and deploy
  ```
      terraform apply
  ```
  7. When done with everything, don't forget to clean up!
  ```
      terraform destroy
  ```
