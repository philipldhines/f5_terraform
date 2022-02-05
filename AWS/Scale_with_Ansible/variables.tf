# Variables

variable "awsRegion" {
  description = "aws region"
  type        = string
  default     = "us-west-2"
}
variable "projectPrefix" {
  type        = string
  description = "prefix for resources"
  default     = "myDemo"
}
variable "resourceOwner" {
  type        = string
  description = "owner of the deployment, for tagging purposes"
  default     = "myName"
}
variable "vpcId" {
  type        = string
  description = "The AWS network VPC ID"
  default     = null
}
variable "mgmtSubnetAz1" {
  type        = string
  description = "ID of Management subnet AZ1"
  default     = null
}
variable "mgmtSubnetAz2" {
  type        = string
  description = "ID of Management subnet AZ2"
  default     = null
}
variable "mgmtSubnetAz3" {
  type        = string
  description = "ID of Management subnet AZ3"
  default     = null
}
variable "extSubnetAz1" {
  type        = string
  description = "ID of External subnet AZ1"
  default     = null
}
variable "extSubnetAz2" {
  type        = string
  description = "ID of External subnet AZ2"
  default     = null
}
variable "extSubnetAz3" {
  type        = string
  description = "ID of External subnet AZ3"
  default     = null
}
variable "intSubnetAz1" {
  type        = string
  description = "ID of Internal subnet AZ1"
  default     = null
}
variable "intSubnetAz2" {
  type        = string
  description = "ID of Internal subnet AZ2"
  default     = null
}
variable "intSubnetAz3" {
  type        = string
  description = "ID of Internal subnet AZ3"
  default     = null
}
variable "mgmtNsg" {
  type        = string
  description = "ID of management security group"
  default     = null
}
variable "extNsg" {
  type        = string
  description = "ID of external security group"
  default     = null
}
variable "intNsg" {
  type        = string
  description = "ID of internal security group"
  default     = null
}
variable "allowedIps" {
  type        = list(any)
  description = "Trusted source network for admin access"
  default     = ["0.0.0.0/0"]
}
variable "f5_ami_search_name" {
  type        = string
  description = "AWS AMI search filter to find correct BIG-IP VE for region"
  default     = "F5 BIGIP-16.1.2.1* PAYG-Best 200Mbps*"
}
variable "ec2_instance_type" {
  type        = string
  description = "AWS instance type for the BIG-IP"
  default     = "m5.xlarge"
}
variable "f5_username" {
  type        = string
  description = "User name for the BIG-IP (Note: currenlty not used. Defaults to 'admin' based on AMI"
  default     = "admin"
}
variable "f5_password" {
  type        = string
  description = "BIG-IP Password"
  default     = "Default12345!"
}
variable "ssh_key" {
  type        = string
  description = "public key used for authentication in ssh-rsa format"
}
variable "dns_server" {
  type        = string
  default     = "8.8.8.8"
  description = "Leave the default DNS server the BIG-IP uses, or replace the default DNS server with the one you want to use"
}
variable "ntp_server" {
  type        = string
  default     = "0.us.pool.ntp.org"
  description = "Leave the default NTP server the BIG-IP uses, or replace the default NTP server with the one you want to use"
}
variable "timezone" {
  type        = string
  default     = "UTC"
  description = "If you would like to change the time zone the BIG-IP uses, enter the time zone you want to use. This is based on the tz database found in /usr/share/zoneinfo (see the full list [here](https://github.com/F5Networks/f5-azure-arm-templates/blob/master/azure-timezone-list.md)). Example values: UTC, US/Pacific, US/Eastern, Europe/London or Asia/Singapore."
}
variable "DO_URL" {
  description = "URL to download the BIG-IP Declarative Onboarding module"
  type        = string
  default     = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.27.0/f5-declarative-onboarding-1.27.0-6.noarch.rpm"
}
variable "AS3_URL" {
  description = "URL to download the BIG-IP Application Service Extension 3 (AS3) module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.34.0/f5-appsvcs-3.34.0-4.noarch.rpm"
}
variable "TS_URL" {
  description = "URL to download the BIG-IP Telemetry Streaming module"
  type        = string
  default     = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.26.0/f5-telemetry-1.26.0-3.noarch.rpm"
}
variable "FAST_URL" {
  description = "URL to download the BIG-IP FAST module"
  type        = string
  default     = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.15.0/f5-appsvcs-templates-1.15.0-1.noarch.rpm"
}
variable "INIT_URL" {
  description = "URL to download the BIG-IP runtime init"
  type        = string
  default     = "https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.4.0/dist/f5-bigip-runtime-init-1.4.0-1.gz.run"
}
variable "libs_dir" {
  description = "Directory on the BIG-IP to download the A&O Toolchain into"
  default     = "/config/cloud/aws/node_modules"
  type        = string
}
variable "onboard_log" {
  description = "Directory on the BIG-IP to store the cloud-init logs"
  default     = "/var/log/cloud/startup-script.log"
  type        = string
}
variable "bigIqHost" {
  type        = string
  default     = ""
  description = "This is the BIG-IQ License Manager host name or IP address"
}
variable "bigIqUsername" {
  type        = string
  default     = "admin"
  description = "Admin name for BIG-IQ"
}
variable "bigIqPassword" {
  type        = string
  default     = "Default12345!"
  description = "Admin Password for BIG-IQ"
}
variable "bigIqLicenseType" {
  type        = string
  default     = "licensePool"
  description = "BIG-IQ license type"
}
variable "bigIqLicensePool" {
  type        = string
  default     = ""
  description = "BIG-IQ license pool name"
}
variable "bigIqSkuKeyword1" {
  type        = string
  default     = "key1"
  description = "BIG-IQ license SKU keyword 1"
}
variable "bigIqSkuKeyword2" {
  type        = string
  default     = "key2"
  description = "BIG-IQ license SKU keyword 2"
}
variable "bigIqUnitOfMeasure" {
  type        = string
  default     = "hourly"
  description = "BIG-IQ license unit of measure"
}
variable "bigIqHypervisor" {
  type        = string
  default     = "aws"
  description = "BIG-IQ hypervisor"
}
variable "sleep_time" {
  type        = string
  default     = "250s"
  description = "The number of seconds/minutes of delay to build into creation of BIG-IP VMs; default is 250. BIG-IP requires a few minutes to complete the onboarding process and this value can be used to delay the processing of dependent Terraform resources."
}
