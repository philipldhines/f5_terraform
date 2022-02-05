# BIG-IP Cluster

############################ AMI ############################

# Find BIG-IP AMI
data "aws_ami" "f5_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]
  filter {
    name   = "name"
    values = [var.f5_ami_search_name]
  }
}

############################ SSH Key pair ############################

# Create SSH Key Pair
resource "aws_key_pair" "bigip" {
  key_name   = format("%s-key-%s", var.projectPrefix, random_id.buildSuffix.hex)
  public_key = var.ssh_key
}

############################ Onboard Scripts ############################

# Setup Onboarding scripts
locals {
  f5_onboard = templatefile("${path.module}/f5_onboard.tmpl", {
    f5_username        = var.f5_username
    f5_password        = var.f5_password
    ssh_keypair        = var.ssh_key
    INIT_URL           = var.INIT_URL
    DO_URL             = var.DO_URL
    AS3_URL            = var.AS3_URL
    TS_URL             = var.TS_URL
    FAST_URL           = var.FAST_URL
    DO_VER             = split("/", var.DO_URL)[7]
    AS3_VER            = split("/", var.AS3_URL)[7]
    TS_VER             = split("/", var.TS_URL)[7]
    FAST_VER           = split("/", var.FAST_URL)[7]
    vpc_cidr_block     = data.aws_vpc.main.cidr_block
    dns_server         = var.dns_server
    ntp_server         = var.ntp_server
    timezone           = var.timezone
    bigIqLicenseType   = var.bigIqLicenseType
    bigIqHost          = var.bigIqHost
    bigIqPassword      = var.bigIqPassword
    bigIqUsername      = var.bigIqUsername
    bigIqLicensePool   = var.bigIqLicensePool
    bigIqSkuKeyword1   = var.bigIqSkuKeyword1
    bigIqSkuKeyword2   = var.bigIqSkuKeyword2
    bigIqUnitOfMeasure = var.bigIqUnitOfMeasure
    bigIqHypervisor    = var.bigIqHypervisor
  })
}

############################ Compute ############################

# Create F5 BIG-IP VMs
module "bigipAZ1" {
  source                     = "F5Networks/bigip-module/aws"
  prefix                     = var.projectPrefix
  ec2_key_name               = aws_key_pair.bigip.key_name
  mgmt_subnet_ids            = [{ "subnet_id" = var.mgmtSubnetAz1, "public_ip" = true, "private_ip_primary" = "" }]
  external_subnet_ids        = [{ "subnet_id" = var.extSubnetAz1, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  internal_subnet_ids        = [{ "subnet_id" = var.intSubnetAz1, "public_ip" = true, "public_ip" = false, "private_ip_primary" = "" }]
  mgmt_securitygroup_ids     = [var.mgmtNsg]
  external_securitygroup_ids = [var.extNsg]
  internal_securitygroup_ids = [var.intNsg]
  custom_user_data           = base64encode(local.f5_onboard)
}

module "bigipAZ2" {
  source                     = "F5Networks/bigip-module/aws"
  prefix                     = var.projectPrefix
  ec2_key_name               = aws_key_pair.bigip.key_name
  mgmt_subnet_ids            = [{ "subnet_id" = var.mgmtSubnetAz2, "public_ip" = true, "private_ip_primary" = "" }]
  external_subnet_ids        = [{ "subnet_id" = var.extSubnetAz2, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  internal_subnet_ids        = [{ "subnet_id" = var.intSubnetAz2, "public_ip" = true, "public_ip" = false, "private_ip_primary" = "" }]
  mgmt_securitygroup_ids     = [var.mgmtNsg]
  external_securitygroup_ids = [var.extNsg]
  internal_securitygroup_ids = [var.intNsg]
  custom_user_data           = base64encode(local.f5_onboard)
}

module "bigipAZ3" {
  source                     = "F5Networks/bigip-module/aws"
  prefix                     = var.projectPrefix
  ec2_key_name               = aws_key_pair.bigip.key_name
  mgmt_subnet_ids            = [{ "subnet_id" = var.mgmtSubnetAz3, "public_ip" = true, "private_ip_primary" = "" }]
  external_subnet_ids        = [{ "subnet_id" = var.extSubnetAz3, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = "" }]
  internal_subnet_ids        = [{ "subnet_id" = var.intSubnetAz3, "public_ip" = true, "public_ip" = false, "private_ip_primary" = "" }]
  mgmt_securitygroup_ids     = [var.mgmtNsg]
  external_securitygroup_ids = [var.extNsg]
  internal_securitygroup_ids = [var.intNsg]
  custom_user_data           = base64encode(local.f5_onboard)
}
