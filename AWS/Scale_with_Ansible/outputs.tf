# Outputs

output "bigip_AZ1_mgmtIP" {
  description = "BIG-IP AZ1 management public IP address"
  value       = module.bigip["az1"].mgmtPublicIP
}
output "bigip_AZ2_mgmtIP" {
  description = "BIG-IP AZ2 management public IP address"
  value       = module.bigip["az2"].mgmtPublicIP
}
output "bigip_AZ3_mgmtIP" {
  description = "BIG-IP AZ3 management public IP address"
  value       = module.bigip["az3"].mgmtPublicIP
}
output "vip_AZ1" {
  description = "VIP Listener on BIG-IP AZ1"
  value       = module.bigip["az1"].public_addresses["external_secondary_public"][0]
}
output "vip_AZ2" {
  description = "VIP Listener on BIG-IP AZ1"
  value       = module.bigip["az2"].public_addresses["external_secondary_public"][0]
}
output "vip_AZ3" {
  description = "VIP Listener on BIG-IP AZ1"
  value       = module.bigip["az3"].public_addresses["external_secondary_public"][0]
}
