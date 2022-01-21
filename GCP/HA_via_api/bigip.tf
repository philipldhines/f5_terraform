# BIG-IP

############################ Password ############################

resource "random_string" "password" {
  length      = 16
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
  special     = false
}

############################ Public IPs and Forwarding Rules ############################

# Public IP for VIP
resource "google_compute_address" "vip1" {
  name = "${var.prefix}-vip1"
}

# Forwarding rule for Public IP
resource "google_compute_forwarding_rule" "vip1" {
  name       = "${var.prefix}-forwarding-rule"
  target     = google_compute_target_instance.f5vm02.id
  ip_address = google_compute_address.vip1.address
  port_range = "1-65535"
}

resource "google_compute_target_instance" "f5vm01" {
  name     = "${var.prefix}-${var.host1_name}-ti"
  instance = module.f5vm01.bigip_instance_ids
}

resource "google_compute_target_instance" "f5vm02" {
  name     = "${var.prefix}-${var.host2_name}-ti"
  instance = module.f5vm02.bigip_instance_ids
}

############################ Private IPs ############################

# Reserve IPs on external subnet for BIG-IP nic0s
resource "google_compute_address" "ext" {
  count        = var.num_instances
  project      = var.gcp_project_id
  name         = format("bigip-ext-%d", count.index)
  subnetwork   = var.extSubnet
  address_type = "INTERNAL"
  region       = replace(var.gcp_zone, "/-[a-z]$/", "")
}

# Reserve VIP on external subnet for BIG-IP
resource "google_compute_address" "vip" {
  project      = var.gcp_project_id
  name         = "bigip-ext-vip"
  subnetwork   = var.extSubnet
  address_type = "INTERNAL"
  region       = replace(var.gcp_zone, "/-[a-z]$/", "")
}

# Reserve IPs on management subnet for BIG-IP nic1s
resource "google_compute_address" "mgmt" {
  count        = var.num_instances
  project      = var.gcp_project_id
  name         = format("bigip-mgmt-%d", count.index)
  subnetwork   = var.mgmtSubnet
  address_type = "INTERNAL"
  region       = replace(var.gcp_zone, "/-[a-z]$/", "")
}

# Reserve IPs on internal subnet for BIG-IP nic2s
resource "google_compute_address" "int" {
  count        = var.num_instances
  project      = var.gcp_project_id
  name         = format("bigip-int-%d", count.index)
  subnetwork   = var.intSubnet
  address_type = "INTERNAL"
  region       = replace(var.gcp_zone, "/-[a-z]$/", "")
}


############################ Startup Scripts ############################

locals {
  vm01_onboard = templatefile("${path.module}/f5_onboard.tmpl", {
    uname                             = var.uname
    usecret                           = var.usecret
    ssh_keypair                       = var.gceSshPubKey
    gcp_secret_manager_authentication = var.gcp_secret_manager_authentication
    gcp_secret_manager_authentication = var.gcp_secret_manager_authentication
    bigip_password                    = (var.f5_password == "") ? (var.gcp_secret_manager_authentication ? var.gcp_secret_name : random_string.password.result) : var.f5_password
    ksecret                           = var.ksecret
    gcp_project_id                    = var.gcp_project_id
    DO_URL                            = var.DO_URL
    AS3_URL                           = var.AS3_URL
    TS_URL                            = var.TS_URL
    CFE_URL                           = var.CFE_URL
    INIT_URL                          = var.INIT_URL
    DO_VER                            = split("/", var.DO_URL)[7]
    AS3_VER                           = split("/", var.AS3_URL)[7]
    TS_VER                            = split("/", var.TS_URL)[7]
    CFE_VER                           = split("/", var.CFE_URL)[7]
    onboard_log                       = var.onboard_log
    f5_cloud_failover_label           = format("%s-%s", var.prefix)
    cfe_managed_route                 = var.managed_route1
    remote_selfip_ext                 = google_compute_address.ext[1].address
    host1                             = "${var.prefix}-${var.host1_name}"
    host2                             = "${var.prefix}-${var.host2_name}"
    remote_host                       = "${var.prefix}-${var.host2_name}"
    dns_server                        = var.dns_server
    ntp_server                        = var.ntp_server
    timezone                          = var.timezone
    publicvip                         = google_compute_address.vip1.address
    privatevip                        = var.alias_ip_range
    NIC_COUNT                         = true
  })
  vm02_onboard = templatefile("${path.module}/f5_onboard.tmpl", {
    uname                             = var.uname
    usecret                           = var.usecret
    ssh_keypair                       = var.gceSshPubKey
    gcp_secret_manager_authentication = var.gcp_secret_manager_authentication
    gcp_secret_manager_authentication = var.gcp_secret_manager_authentication
    bigip_password                    = (var.f5_password == "") ? (var.gcp_secret_manager_authentication ? var.gcp_secret_name : random_string.password.result) : var.f5_password
    ksecret                           = var.ksecret
    gcp_project_id                    = var.gcp_project_id
    DO_URL                            = var.DO_URL
    AS3_URL                           = var.AS3_URL
    TS_URL                            = var.TS_URL
    CFE_URL                           = var.CFE_URL
    INIT_URL                          = var.INIT_URL
    DO_VER                            = split("/", var.DO_URL)[7]
    AS3_VER                           = split("/", var.AS3_URL)[7]
    TS_VER                            = split("/", var.TS_URL)[7]
    CFE_VER                           = split("/", var.CFE_URL)[7]
    onboard_log                       = var.onboard_log
    f5_cloud_failover_label           = format("%s-%s", var.prefix)
    cfe_managed_route                 = var.managed_route1
    remote_selfip_ext                 = google_compute_address.ext[1].address
    host1                             = "${var.prefix}-${var.host1_name}"
    host2                             = "${var.prefix}-${var.host2_name}"
    remote_host                       = google_compute_address.mgmt[0].address
    dns_server                        = var.dns_server
    ntp_server                        = var.ntp_server
    timezone                          = var.timezone
    publicvip                         = google_compute_address.vip1.address
    privatevip                        = var.alias_ip_range
    NIC_COUNT                         = true
  })
  vm01_do_json = templatefile("${path.module}/do.json", {
    regKey             = var.license1
    admin_username     = var.uname
    host1              = "${var.prefix}-${var.host1_name}"
    host2              = "${var.prefix}-${var.host2_name}"
    remote_host        = "${var.prefix}-${var.host2_name}"
    dns_server         = var.dns_server
    dns_suffix         = var.dns_suffix
    ntp_server         = var.ntp_server
    timezone           = var.timezone
    bigIqLicenseType   = var.bigIqLicenseType
    bigIqHost          = var.bigIqHost
    bigIqUsername      = var.bigIqUsername
    bigIqLicensePool   = var.bigIqLicensePool
    bigIqSkuKeyword1   = var.bigIqSkuKeyword1
    bigIqSkuKeyword2   = var.bigIqSkuKeyword2
    bigIqUnitOfMeasure = var.bigIqUnitOfMeasure
    bigIqHypervisor    = var.bigIqHypervisor
  })
  vm02_do_json = templatefile("${path.module}/do.json", {
    regKey             = var.license2
    admin_username     = var.uname
    host1              = "${var.prefix}-${var.host1_name}"
    host2              = "${var.prefix}-${var.host2_name}"
    remote_host        = google_compute_address.mgmt[0].address
    dns_server         = var.dns_server
    dns_suffix         = var.dns_suffix
    ntp_server         = var.ntp_server
    timezone           = var.timezone
    bigIqLicenseType   = var.bigIqLicenseType
    bigIqHost          = var.bigIqHost
    bigIqUsername      = var.bigIqUsername
    bigIqLicensePool   = var.bigIqLicensePool
    bigIqSkuKeyword1   = var.bigIqSkuKeyword1
    bigIqSkuKeyword2   = var.bigIqSkuKeyword2
    bigIqUnitOfMeasure = var.bigIqUnitOfMeasure
    bigIqHypervisor    = var.bigIqHypervisor
  })
  as3_json = templatefile("${path.module}/as3.json", {
    gcp_region = var.gcp_region
    #publicvip  = "0.0.0.0"
    publicvip  = google_compute_address.vip1.address
    privatevip = var.alias_ip_range
  })
  ts_json = templatefile("${path.module}/ts.json", {
    gcp_project_id = var.gcp_project_id
    svc_acct       = var.svc_acct
    privateKeyId   = var.privateKeyId
  })
  vm01_cfe_json = templatefile("${path.module}/cfe.json", {
    f5_cloud_failover_label = var.f5_cloud_failover_label
    managed_route1          = var.managed_route1
    remote_selfip           = ""
  })
  vm02_cfe_json = templatefile("${path.module}/cfe.json", {
    f5_cloud_failover_label = var.f5_cloud_failover_label
    managed_route1          = var.managed_route1
    remote_selfip           = google_compute_address.ext[0].address
  })
}

############################ Compute ############################

# Create F5 BIG-IP VMs
module "f5vm01" {
  source              = "F5Networks/bigip-module/gcp"
  prefix              = var.prefix
  project_id          = var.gcp_project_id
  zone                = var.gcp_zone
  image               = var.image_name
  service_account     = var.svc_acct
  f5_username         = var.uname
  f5_ssh_publickey    = var.gceSshPubKey
  mgmt_subnet_ids     = [{ "subnet_id" = var.mgmtSubnet, "public_ip" = true, "private_ip_primary" = google_compute_address.mgmt[0].address }]
  external_subnet_ids = [{ "subnet_id" = var.extSubnet, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = google_compute_address.ext[0].address }]
  internal_subnet_ids = [{ "subnet_id" = var.intSubnet, "public_ip" = false, "private_ip_primary" = "", "private_ip_secondary" = google_compute_address.int[0].address }]
  custom_user_data    = local.vm01_onboard
}

module "f5vm02" {
  source              = "F5Networks/bigip-module/gcp"
  prefix              = var.prefix
  project_id          = var.gcp_project_id
  zone                = var.gcp_zone
  image               = var.image_name
  service_account     = var.svc_acct
  f5_username         = var.uname
  f5_ssh_publickey    = var.gceSshPubKey
  mgmt_subnet_ids     = [{ "subnet_id" = var.mgmtSubnet, "public_ip" = true, "private_ip_primary" = google_compute_address.mgmt[1].address }]
  external_subnet_ids = [{ "subnet_id" = var.extSubnet, "public_ip" = true, "private_ip_primary" = "", "private_ip_secondary" = google_compute_address.ext[1].address }]
  internal_subnet_ids = [{ "subnet_id" = var.intSubnet, "public_ip" = false, "private_ip_primary" = "", "private_ip_secondary" = google_compute_address.int[1].address }]
  custom_user_data    = local.vm02_onboard
}

# resource "google_compute_instance" "f5vm01" {
#   name           = "${var.prefix}-${var.host1_name}"
#   machine_type   = var.bigipMachineType
#   zone           = var.gcp_zone
#   can_ip_forward = true

#   labels = {
#     f5_cloud_failover_label = var.f5_cloud_failover_label
#   }

#   tags = ["appfw-${var.prefix}", "mgmtfw-${var.prefix}"]

#   boot_disk {
#     initialize_params {
#       image = var.customImage != "" ? var.customImage : var.image_name
#       size  = "128"
#     }
#   }

#   network_interface {
#     network    = var.extVpc
#     subnetwork = var.extSubnet
#     access_config {
#     }
#   }

#   network_interface {
#     network    = var.mgmtVpc
#     subnetwork = var.mgmtSubnet
#     access_config {
#     }
#   }

#   network_interface {
#     network    = var.intVpc
#     subnetwork = var.intSubnet
#   }

#   metadata = {
#     ssh-keys               = "${var.uname}:${var.gceSshPubKey}"
#     block-project-ssh-keys = true
#     startup-script         = var.customImage != "" ? var.customUserData : local.vm01_onboard
#   }

#   service_account {
#     email  = var.svc_acct
#     scopes = ["cloud-platform"]
#   }
# }

# resource "google_compute_instance" "f5vm02" {
#   name           = "${var.prefix}-${var.host2_name}"
#   machine_type   = var.bigipMachineType
#   zone           = var.gcp_zone
#   can_ip_forward = true

#   labels = {
#     f5_cloud_failover_label = var.f5_cloud_failover_label
#   }

#   tags = ["appfw-${var.prefix}", "mgmtfw-${var.prefix}"]

#   boot_disk {
#     initialize_params {
#       image = var.customImage != "" ? var.customImage : var.image_name
#       size  = "128"
#     }
#   }

#   network_interface {
#     network    = var.extVpc
#     subnetwork = var.extSubnet
#     access_config {
#     }
#     alias_ip_range {
#       ip_cidr_range = var.alias_ip_range
#     }
#   }

#   network_interface {
#     network    = var.mgmtVpc
#     subnetwork = var.mgmtSubnet
#     access_config {
#     }
#   }

#   network_interface {
#     network    = var.intVpc
#     subnetwork = var.intSubnet
#   }

#   metadata = {
#     ssh-keys               = "${var.uname}:${var.gceSshPubKey}"
#     block-project-ssh-keys = true
#     startup-script         = var.customImage != "" ? var.customUserData : local.vm02_onboard
#   }

#   service_account {
#     email  = var.svc_acct
#     scopes = ["cloud-platform"]
#   }
# }

# # Troubleshooting - create local output files
# resource "local_file" "onboard_file" {
#   content  = local.vm01_onboard
#   filename = "${path.module}/vm01_onboard.tpl_data.json"
# }
