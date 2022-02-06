# Deploying BIG-IP VE in AWS Using 3 Availability Zones

## To Do
- Community support only. Not F5 supported.
- Move to AWS secret manager. Currently passwords are stored in clear text in the runtime init YAML file local to the BIG-IP box.
- TS still not used and not installed

## Issues
- Find an issue? Fork, clone, create branch, fix and PR. I'll review and merge into the main branch. Or submit a GitHub issue with all necessary details and logs.


## Contents

- [Introduction](#introduction)
- [Prerequisites](#prerequisites)
- [Important Configuration Notes](#important-configuration-notes)
- [BIG-IQ License Manager](#big-iq-license-manager)
- [Installation Example](#installation-example)
- [Configuration Example](#configuration-example)
- [Troubleshooting](#troubleshooting)

## Introduction

This solution uses a Terraform template to launch a 3-NIC deployment of cloud-focused BIG-IP VE devices in AWS across three AWS Availability Zones. Traffic flows to the BIG-IP VE which then processes the traffic to application servers. The BIG-IP VE instances are running with multiple interfaces: management, external, internal. NIC1 is associated with the external network while NIC2 is associated with the internal network.

The BIG-IP VEs have the [Local Traffic Manager (LTM)](https://f5.com/products/big-ip/local-traffic-manager-ltm) module enabled to provide advanced traffic management functionality. In addition, the [Application Security Module (ASM)](https://www.f5.com/pdf/products/big-ip-application-security-manager-overview.pdf) can be enabled to provide F5's L4/L7 security features for web application firewall (WAF) and bot protection.

The BIG-IP's configuration, now defined in a single convenient YAML or JSON [F5 BIG-IP Runtime Init](https://github.com/F5Networks/f5-bigip-runtime-init) configuration file, leverages [F5 Automation Tool Chain](https://www.f5.com/pdf/products/automation-toolchain-overview.pdf) declarations which are easier to author, validate and maintain as code. For instance, if you need to change the configuration on the BIG-IPs in the deployment, you update the instance model by passing a new config file (which references the updated Automation Toolchain declarations) via template's runtimeConfig input parameter. New instances will be deployed with the updated configurations.


## Prerequisites

- ***Important***: When you configure the admin password for the BIG-IP VE in the template, you cannot use the character **#**.  Additionally, there are a number of other special characters that you should avoid using for F5 product user accounts.  See [K2873](https://support.f5.com/csp/article/K2873) for details.
- This template requires one or more service accounts for the BIG-IP instance to perform various tasks:
  - AWS Secrets Manager - requires (TBD...not tested yet)
    - Performed by VM instance during onboarding to retrieve passwords and private keys
  - Backend pool service discovery - requires various roles
    - Performed by F5 Application Services AS3
- These BIG-IP VMs are deployed across different Availability Zones
- This template requires programmatic API credentials to deploy the Terraform AWS provider and build out all the neccessary AWS objects
  - See the [Terraform "AWS Provider"](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication) for details
  - You will require at minimum `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
  - ***Note***: Make sure to [practice least privilege](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- This templates deploys into an *EXISTING* networking stack. You are required to have an existing VPC network, subnets, and security groups.
  - A NAT gateway or public IP is also required for outbound Internet traffic
  - If you require a new network first, see the [Infrastructure Only folder](../Infrastructure-only) to get started


## Important Configuration Notes

- Variables are configured in variables.tf
- Sensitive variables like AWS SSH keys are configured in terraform.tfvars or AWS Secrets Manager
  - ***Note***: Passwords and secrets will be moved to AWS Secrets Manager in the future
  - (TBD) The BIG-IP instance will query AWS Metadata API to retrieve the service account's token for authentication
  - (TBD) The BIG-IP instance will then use the secret name and the service account's token to query AWS Metadata API and dynamically retrieve the password for device onboarding
- This template uses Declarative Onboarding (DO), Application Services 3 (AS3), and Cloud Failover Extension packages for the initial configuration. As part of the onboarding script, it will download the RPMs automatically. See the [AS3 documentation](http://f5.com/AS3Docs) and [DO documentation](http://f5.com/DODocs) for details on how to use AS3 and Declarative Onboarding on your BIG-IP VE(s). The [Telemetry Streaming](http://f5.com/TSDocs) extension is also downloaded and can be configured to point to AWS Cloud Watch.

- Files
  - bigip.tf - resources for BIG-IP, NICs, public IPs
  - main.tf - resources for provider, versions, storage buckets
  - bigip.tf - resources for BIG-IP, security groups, route table
  - f5_onboard.tmpl - onboarding script which is run by user-data. This script is responsible for downloading the neccessary F5 Automation Toolchain RPM files, installing them, and then executing the onboarding REST calls via the [BIG-IP Runtime Init tool](https://github.com/F5Networks/f5-bigip-runtime-init).

## BIG-IQ License Manager
This template uses PayGo BIG-IP image for the deployment (as default). If you would like to use BYOL/ELA/Subscription licenses from [BIG-IQ License Manager (LM)](https://devcentral.f5.com/s/articles/managing-big-ip-licensing-with-big-iq-31944), then these following steps are needed:
1. In the "variables.tf", modify *f5_ami_search_name* value with a BYOL filter in the name. Example below...
  ```
          # BIGIP Image
          variable "f5_ami_search_name" { default = "F5 BIGIP-16.1.2.1* BYOL-All* 2Boot*" }
  ```
2. In the "variables.tf", modify the BIG-IQ license section to match your environment
3. In the "f5_onboard.tmpl", add the "myLicense" block under the "Common" declaration ([example here](https://github.com/F5Networks/f5-aws-cloudformation-v2/blob/main/examples/autoscale/bigip-configurations/runtime-init-conf-bigiq.yaml))
  ```
          myLicense:
            class: License
            licenseType: ${bigIqLicenseType}
            bigIqHost: ${bigIqHost}
            bigIqUsername: ${bigIqUsername}
            bigIqPassword: ${bigIqPassword}
            licensePool: ${bigIqLicensePool}
            skuKeyword1: ${bigIqSkuKeyword1}
            skuKeyword2: ${bigIqSkuKeyword2}
            unitOfMeasure: ${bigIqUnitOfMeasure}
            reachable: false
            hypervisor: ${bigIqHypervisor}
            overwrite: true
  ```

<!-- markdownlint-disable no-inline-html -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bigip"></a> [bigip](#module\_bigip) | F5Networks/bigip-module/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.bigip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [random_id.buildSuffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ami.f5_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | public key used for authentication in ssh-rsa format | `string` | n/a | yes |
| <a name="input_AS3_URL"></a> [AS3\_URL](#input\_AS3\_URL) | URL to download the BIG-IP Application Service Extension 3 (AS3) module | `string` | `"https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.34.0/f5-appsvcs-3.34.0-4.noarch.rpm"` | no |
| <a name="input_DO_URL"></a> [DO\_URL](#input\_DO\_URL) | URL to download the BIG-IP Declarative Onboarding module | `string` | `"https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.27.0/f5-declarative-onboarding-1.27.0-6.noarch.rpm"` | no |
| <a name="input_FAST_URL"></a> [FAST\_URL](#input\_FAST\_URL) | URL to download the BIG-IP FAST module | `string` | `"https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.15.0/f5-appsvcs-templates-1.15.0-1.noarch.rpm"` | no |
| <a name="input_INIT_URL"></a> [INIT\_URL](#input\_INIT\_URL) | URL to download the BIG-IP runtime init | `string` | `"https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.4.0/dist/f5-bigip-runtime-init-1.4.0-1.gz.run"` | no |
| <a name="input_TS_URL"></a> [TS\_URL](#input\_TS\_URL) | URL to download the BIG-IP Telemetry Streaming module | `string` | `"https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.26.0/f5-telemetry-1.26.0-3.noarch.rpm"` | no |
| <a name="input_allowedIps"></a> [allowedIps](#input\_allowedIps) | Trusted source network for admin access | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_awsRegion"></a> [awsRegion](#input\_awsRegion) | aws region | `string` | `"us-west-2"` | no |
| <a name="input_bigIqHost"></a> [bigIqHost](#input\_bigIqHost) | This is the BIG-IQ License Manager host name or IP address | `string` | `""` | no |
| <a name="input_bigIqHypervisor"></a> [bigIqHypervisor](#input\_bigIqHypervisor) | BIG-IQ hypervisor | `string` | `"aws"` | no |
| <a name="input_bigIqLicensePool"></a> [bigIqLicensePool](#input\_bigIqLicensePool) | BIG-IQ license pool name | `string` | `""` | no |
| <a name="input_bigIqLicenseType"></a> [bigIqLicenseType](#input\_bigIqLicenseType) | BIG-IQ license type | `string` | `"licensePool"` | no |
| <a name="input_bigIqPassword"></a> [bigIqPassword](#input\_bigIqPassword) | Admin Password for BIG-IQ | `string` | `"Default12345!"` | no |
| <a name="input_bigIqSkuKeyword1"></a> [bigIqSkuKeyword1](#input\_bigIqSkuKeyword1) | BIG-IQ license SKU keyword 1 | `string` | `"key1"` | no |
| <a name="input_bigIqSkuKeyword2"></a> [bigIqSkuKeyword2](#input\_bigIqSkuKeyword2) | BIG-IQ license SKU keyword 2 | `string` | `"key2"` | no |
| <a name="input_bigIqUnitOfMeasure"></a> [bigIqUnitOfMeasure](#input\_bigIqUnitOfMeasure) | BIG-IQ license unit of measure | `string` | `"hourly"` | no |
| <a name="input_bigIqUsername"></a> [bigIqUsername](#input\_bigIqUsername) | Admin name for BIG-IQ | `string` | `"admin"` | no |
| <a name="input_dns_server"></a> [dns\_server](#input\_dns\_server) | Leave the default DNS server the BIG-IP uses, or replace the default DNS server with the one you want to use | `string` | `"8.8.8.8"` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | AWS instance type for the BIG-IP | `string` | `"m5.xlarge"` | no |
| <a name="input_extNsg"></a> [extNsg](#input\_extNsg) | ID of external security group | `string` | `null` | no |
| <a name="input_extSubnetAz1"></a> [extSubnetAz1](#input\_extSubnetAz1) | ID of External subnet AZ1 | `string` | `null` | no |
| <a name="input_extSubnetAz2"></a> [extSubnetAz2](#input\_extSubnetAz2) | ID of External subnet AZ2 | `string` | `null` | no |
| <a name="input_extSubnetAz3"></a> [extSubnetAz3](#input\_extSubnetAz3) | ID of External subnet AZ3 | `string` | `null` | no |
| <a name="input_f5_ami_search_name"></a> [f5\_ami\_search\_name](#input\_f5\_ami\_search\_name) | AWS AMI search filter to find correct BIG-IP VE for region | `string` | `"F5 BIGIP-16.1.2.1* PAYG-Best 200Mbps*"` | no |
| <a name="input_f5_password"></a> [f5\_password](#input\_f5\_password) | BIG-IP Password | `string` | `"Default12345!"` | no |
| <a name="input_f5_username"></a> [f5\_username](#input\_f5\_username) | User name for the BIG-IP (Note: currenlty not used. Defaults to 'admin' based on AMI | `string` | `"admin"` | no |
| <a name="input_intNsg"></a> [intNsg](#input\_intNsg) | ID of internal security group | `string` | `null` | no |
| <a name="input_intSubnetAz1"></a> [intSubnetAz1](#input\_intSubnetAz1) | ID of Internal subnet AZ1 | `string` | `null` | no |
| <a name="input_intSubnetAz2"></a> [intSubnetAz2](#input\_intSubnetAz2) | ID of Internal subnet AZ2 | `string` | `null` | no |
| <a name="input_intSubnetAz3"></a> [intSubnetAz3](#input\_intSubnetAz3) | ID of Internal subnet AZ3 | `string` | `null` | no |
| <a name="input_libs_dir"></a> [libs\_dir](#input\_libs\_dir) | Directory on the BIG-IP to download the A&O Toolchain into | `string` | `"/config/cloud/aws/node_modules"` | no |
| <a name="input_mgmtNsg"></a> [mgmtNsg](#input\_mgmtNsg) | ID of management security group | `string` | `null` | no |
| <a name="input_mgmtSubnetAz1"></a> [mgmtSubnetAz1](#input\_mgmtSubnetAz1) | ID of Management subnet AZ1 | `string` | `null` | no |
| <a name="input_mgmtSubnetAz2"></a> [mgmtSubnetAz2](#input\_mgmtSubnetAz2) | ID of Management subnet AZ2 | `string` | `null` | no |
| <a name="input_mgmtSubnetAz3"></a> [mgmtSubnetAz3](#input\_mgmtSubnetAz3) | ID of Management subnet AZ3 | `string` | `null` | no |
| <a name="input_ntp_server"></a> [ntp\_server](#input\_ntp\_server) | Leave the default NTP server the BIG-IP uses, or replace the default NTP server with the one you want to use | `string` | `"0.us.pool.ntp.org"` | no |
| <a name="input_onboard_log"></a> [onboard\_log](#input\_onboard\_log) | Directory on the BIG-IP to store the cloud-init logs | `string` | `"/var/log/cloud/startup-script.log"` | no |
| <a name="input_projectPrefix"></a> [projectPrefix](#input\_projectPrefix) | prefix for resources | `string` | `"myDemo"` | no |
| <a name="input_resourceOwner"></a> [resourceOwner](#input\_resourceOwner) | owner of the deployment, for tagging purposes | `string` | `"myName"` | no |
| <a name="input_sleep_time"></a> [sleep\_time](#input\_sleep\_time) | The number of seconds/minutes of delay to build into creation of BIG-IP VMs; default is 250. BIG-IP requires a few minutes to complete the onboarding process and this value can be used to delay the processing of dependent Terraform resources. | `string` | `"250s"` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | If you would like to change the time zone the BIG-IP uses, enter the time zone you want to use. This is based on the tz database found in /usr/share/zoneinfo (see the full list [here](https://github.com/F5Networks/f5-azure-arm-templates/blob/master/azure-timezone-list.md)). Example values: UTC, US/Pacific, US/Eastern, Europe/London or Asia/Singapore. | `string` | `"UTC"` | no |
| <a name="input_vpcId"></a> [vpcId](#input\_vpcId) | The AWS network VPC ID | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bigip_AZ1_mgmtIP"></a> [bigip\_AZ1\_mgmtIP](#output\_bigip\_AZ1\_mgmtIP) | BIG-IP AZ1 management public IP address |
| <a name="output_bigip_AZ2_mgmtIP"></a> [bigip\_AZ2\_mgmtIP](#output\_bigip\_AZ2\_mgmtIP) | BIG-IP AZ2 management public IP address |
| <a name="output_bigip_AZ3_mgmtIP"></a> [bigip\_AZ3\_mgmtIP](#output\_bigip\_AZ3\_mgmtIP) | BIG-IP AZ3 management public IP address |
| <a name="output_vip_AZ1"></a> [vip\_AZ1](#output\_vip\_AZ1) | VIP Listener on BIG-IP AZ1 |
| <a name="output_vip_AZ2"></a> [vip\_AZ2](#output\_vip\_AZ2) | VIP Listener on BIG-IP AZ1 |
| <a name="output_vip_AZ3"></a> [vip\_AZ3](#output\_vip\_AZ3) | VIP Listener on BIG-IP AZ1 |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- markdownlint-enable no-inline-html -->

## Installation Example

To run this Terraform template, perform the following steps:
  1. Clone the repo to your favorite location
  2. Modify terraform.tfvars with the required information
  ```
      # BIG-IP Environment
      allowedIps    = ["0.0.0.0/0"]
      vpcId         = "vpc-1234"
      mgmtSubnetAz1 = "subnet-1111"
      mgmtSubnetAz2 = "subnet-2222"
      mgmtSubnetAz3 = "subnet-3333"
      extSubnetAz1  = "subnet-4444"
      extSubnetAz2  = "subnet-5555"
      extSubnetAz3  = "subnet-6666"
      intSubnetAz1  = "subnet-7777"
      intSubnetAz2  = "subnet-8888"
      intSubnetAz3  = "subnet-9999"
      mgmtNsg       = "sg-1111"
      extNsg        = "sg-4444"
      intNsg        = "sg-7777"
      ssh_key       = "ssh-rsa AAABC123....."
      f5_username   = "admin"
      f5_password   = "Default12345!"

      # AWS Environment
      awsRegion     = "us-west-2"
      projectPrefix = "3AZdemo"
      resourceOwner = "myname"
  ```
  3. Initialize the directory
  ```
      terraform init
  ```
  4. Test the plan and validate errors
  ```
      terraform plan
  ```
  5. Finally, apply and deploy
  ```
      terraform apply
  ```
  6. When done with everything, don't forget to clean up!
  ```
      terraform destroy
  ```

## Configuration Example

The following is an example configuration diagram for this solution deployment. In this scenario, all access to the BIG-IP VE devices is direct to each BIG-IP via the management interface. The IP addresses in this example may be different in your implementation.

![Configuration Example TBD](./images/aws-standalone-example.png)

## Documentation

For more information on F5 solutions for AWS, including manual configuration procedures for some deployment scenarios, see the AWS section of [F5 CloudDocs](https://clouddocs.f5.com/cloud/public/v1/aws_index.html). Also check out the [Using Cloud Templates for BIG-IP in AWS](https://devcentral.f5.com/s/articles/Using-Cloud-Templates-to-Change-BIG-IP-Versions-AWS) on DevCentral.

## Creating Virtual Servers on the BIG-IP VE

TODO

In order to pass traffic from your clients to the servers through the BIG-IP system, you must create a virtual server on each BIG-IP VE. This demo creates a demo virtual server using Ansible to configure all BIG-IP devices with identical application services. See xyz...PENDING TBD.

## Troubleshooting

### Device Logs
Access the BIG-IP device via SSH and review the startup-script.log file for errors.
- /var/log/cloud/startup-script.log

### F5 Automation Toolchain Components
F5 BIG-IP Runtime Init uses the F5 Automation Toolchain for configuration of BIG-IP instances.  Any errors thrown from these components will be surfaced in the bigIpRuntimeInit.log (or a custom log location as specified below).

Help with troubleshooting individual Automation Toolchain components can be found at F5's [Public Cloud Docs](http://clouddocs.f5.com/cloud/public/v1/):
- DO: https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/troubleshooting.html
- AS3: https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/userguide/troubleshooting.html
- FAST: https://clouddocs.f5.com/products/extensions/f5-appsvcs-templates/latest/userguide/troubleshooting.html
- TS: https://clouddocs.f5.com/products/extensions/f5-telemetry-streaming/latest/userguide/troubleshooting.html
